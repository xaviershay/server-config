class Context
  attr_reader :ssh

  def initialize(ssh)
    @ssh = ssh
    @vars = {}
  end

  def run(cmd)
    execute_ssh_command(cmd)
  end
  
  def run_script(location)
    script = File.read("scripts/#{location}").gsub("\r\n", "\n")
    execute_ssh_command(script, log: true)
  end

  def upload_file(file, content)
    temp_file = "/tmp/#{File.basename(file)}"
    # TODO: Don't hard code host here. And maybe try to reuse SFTP connection
    Net::SFTP.start('styx.local', 'xavier') do |sftp|
      sftp.file.open(temp_file, "w", 600) do |f|
        f.write(content)
      end
    end
    run("sudo mv #{temp_file} #{file}")
  end

  def store_variable(key, value)
    @vars[key] = value
  end

  def read_variable(key)
    @vars.fetch(key)
  end

  alias_method :v, :read_variable

  private

  def execute_ssh_command(command, log: false)
    stdout = ""
    stderr = ""
    exit_code = nil

    ssh.open_channel do |channel|
      channel.exec(command) do |ch, success|
        raise "command execution failed: #{command[0..20]}..." unless success
      end

      channel.on_data do |ch, data|
        stdout << data
        log_output(data) if log
      end

      channel.on_extended_data do |ch, type, data|
        stderr << data
        log_output(data) if log
      end

      channel.on_request("exit-status") do |ch, data|
        exit_code = data.read_long
      end
    end
    ssh.loop

    raise "command execution failed: #{command}\n#{stderr}" if exit_code != 0
    stdout.chomp
  end

  def log_output(data)
    puts data
  end
end
