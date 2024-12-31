require 'net/ssh'
require 'set'

class TaskDefinition
  def met?(*args, &block)
    @met = block
  end

  def meet(*args, &block)
    @meet = block
  end

  def _met; @met end
  def _meet; @meet end
end

TaskSpec = Data.define(:name, :depends, :block)

class Context
  attr_reader :ssh

  def initialize(ssh)
    @ssh = ssh
  end

  def run(cmd)
    puts "run: #{cmd}"
    stdout = ""
    stderr = ""
    exit_code = nil
    ssh.open_channel do |channel|
      channel.exec(cmd) do |ch, success|
        raise "command execution failed: #{cmd}" unless success
      end

      channel.on_data do |ch, data|
        stdout << data
      end

      # Handle stderr data
      channel.on_extended_data do |ch, type, data|
        stderr << data
      end

      channel.on_request("exit-status") do |ch, data|
        exit_code = data.read_long
      end
    end
    ssh.loop
    if exit_code != 0
      return ""
    else
      stdout
    end
  end
  
  def run_script(location)
    puts "run script: #{location}"
  end
end

class Babs
  # Progress until a met? is not met then halt
  def plan
    Net::SSH.start('styx.local') do |ssh|
      @completed = Set.new
      @context = Context.new(ssh)
      root = self.class.root
      root.each do |task_name|
        run_task(task_name)
      end
    end
  end

  def run_task(task_name)
    return if @completed.include?(task_name)

    puts task_name
    task = self.class.tasks.fetch(task_name)
    task.depends.each do |dep|
      run_task(dep)
    end
    if task.block
      t = TaskDefinition.new
      t.instance_exec(&task.block)

      met = @context.instance_exec(&t._met)
      unless met
        @context.instance_exec(&t._meet)
        met = @context.instance_exec(&t._met)
        unless met
          raise "task not met after meeting: #{task_name}"
        end
      end
    end
    @completed << task.name
  end

  # Progress fully
  def apply
  end

  def self.root; @root end
  def self.tasks; @tasks end

  def self.root_task(deps)
    @root = deps
  end

  def self.task(name, depends: [], &block)
    @tasks ||= {}
    @tasks[name] = TaskSpec.new(
      name,
      [*depends],
      block
    )
  end

  def self.sftp_task(name, file, depends: [], &block)
    # TODO
    @tasks ||= {}
    @tasks[name] = TaskSpec.new(
      name,
      [*depends],
      block
    )
  end
end

class Styx < Babs
  task 'influxdb: install' do
    met? { run("influxd version").start_with?("InfluxDB v2.7.11") }
    meet {
      run_script("install_influxdb.bash")
    }
  end

  task 'influxdb: run' do
    met? { false } # TODO: Copy health check from ansible
    meet {
      run("sudo systemctl restart influxdb")
    }
  end

  sftp_task 'influxdb: configure', [
    '/etc/influxdb2/config.yml'
  ]

  task 'influxdb', depends: [
    'influxdb: install',
    'influxdb: configure',
    'influxdb: run'
  ]

  %w(system sensors).each do |bucket_name|
    task "ensure influx bucket: #{bucket_name}", depends: 'influxdb' do
      met? {
        buckets = JSON.parse(run("influx bucket list --json"))
        bucket = buckets.find {|x| x.fetch('name') == name }
        if bucket
          store_variable "influxdb.buckets.#{bucket_name}", bucket.fetch('id')
        end
      }
      meet {
        run("influx bucket create --name %s" % [
          name,
        ])
      }
    end
  end

  {
    grafana: {read: ['system', 'sensor']},
    telegraf: {write: ['system']}
  }.each do |description, permissions|
    task "ensure influxdb token: #{description}", depends: 'influxdb' do
      met? {
        tokens = JSON.parse(run("influx auth list --json"))
        token = tokens.find {|x| x.fetch('description') == description }
        if token
          store_variable 'telegraf.influxdb.api_token', token.fetch('token')
        end
      }
      meet {
        flags = ""
        flags << permissions.fetch(:read, []).map {|x|
          "--read-bucket %s" % read_variable("influxdb.buckets.#{x}")
        }
        flags << permissions.fetch(:write, []).map {|x|
          "--write-bucket" % read_variable("influxdb.buckets.#{x}")
        }
        run("influx auth create --description \"%s\" %s" % [
          description,
          flags
        ])
      }
    end
  end

  task 'telegraf: install' do
    met? { false } # TODO run("influxd version").start_with?("InfluxDB v2.7.11") }
    meet {
      run_script("install_telegraf.bash")
    }
  end

  sftp_task 'telegraf: configure', [
    '/etc/telegraf/telegraf.conf'
  ], depends: 'ensure influxdb token: telegraf'

  task 'telegraf: run' do
    met? { false } # TODO: Copy health check from ansible
    meet {
      run("sudo systemctl restart telegraf")
    }
  end

  task 'telegraf', depends: [
    'telegraf: install',
    'telegraf: configure',
    'telegraf: run'
  ]

  root_task [
    'influxdb',
    'telegraf'
  ]
end

Styx.new.plan