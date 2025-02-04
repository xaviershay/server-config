require 'net/ssh'
require 'context'
require 'ssh_context'
require 'set'
require 'json'
require 'erb'
require 'net/sftp'

require 'keyctl_json_secrets'

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

class Babs
  def self.systemctl_enable_task(service)
    ->{ met? { raise("Unimplemented") } }
  end

  def self.systemctl_run_task(service)
    ->{ met? { raise("Unimplemented") } }
  end

  def self.enable_task(service)
    ->{ met? { raise("Unimplemented") } }
  end

  def self.run_task(service)
    ->{ met? { raise("Unimplemented") } }
  end

  def initialize(logger: $stdout, meet: true)
    @logger = logger
    @meet = meet
  end

  def apply(context = Context.new, filter: "")
    @context = context
    @completed = Set.new
    self.class.vars.each do |key, value|
      @context.store_variable key, value
    end
    root = self.class.root
    root.each do |task_name|
      next unless task_name.start_with?(filter)
      run_task(task_name)
    end

    # Relies on Set maintaining insertion order when converted
    @completed.to_a
  end

  def run_task(task_name)
    return if @completed.include?(task_name)

    task = self.class.tasks.fetch(task_name)
    task.depends.each do |dep|
      run_task(dep)
    end
    if task.block
      t = TaskDefinition.new
      t.instance_exec(&task.block)

      met = @context.instance_exec(&t._met)
      @logger.puts "%s %s" % [met ? "✓" : "✗", task_name]
      unless met
        raise "unmet task: #{task_name}" unless @meet
        @context.instance_exec(&t._meet)
        met = @context.instance_exec(&t._met)
        @logger.puts "%s %s" % [met ? "✓" : "✗", task_name]
        unless met
          raise "task not met after meeting: #{task_name}"
        end
      end
    end
    @completed << task.name
  end

  def self.root; @root ||= [] end
  def self.tasks; @tasks ||= [] end
  def self.vars; @vars ||= {} end

  def self.root_task(deps)
    @root = [*deps]
  end

  def self.task(name, depends: [], &block)
    @tasks ||= {}
    @tasks[name] = TaskSpec.new(
      name,
      [*depends],
      block
    )
  end

  def self.sftp_task(name, files, perms, depends: [], group: nil, after_meet: ->{})
    files = [*files]
    upload_tasks = files.map do |file|
      task_name = name + ": #{file}"
      task task_name, depends: depends do
        met? {
          filename = File.join("templates", file)
          erb = ERB.new(File.read(filename))
          erb.filename = filename
          @local_content = erb.result(binding)
          remote_digest = run_root("md5sum #{file} | head -c 32")
          remote_perms, remote_group = *run_root("stat -c '%a %G' #{file} || true").split(" ")
          local_digest = Digest::MD5.hexdigest(@local_content)
          local_digest == remote_digest && remote_perms.to_i == perms.to_i && (!group || group == remote_group)
        }
        meet {
          upload_file file, @local_content, perms, group: group
          instance_exec(&after_meet)
        }
      end
      task_name
    end
    task name, depends: upload_tasks
  end

  def self.variables(mappings)
    @vars = mappings
  end

  def self.secret(name)
    @secrets ||= KeyctlJsonSecrets.new
    ->{ @secrets.read(name) }
  end
end
