class SSHContext < Context
  attr_reader :ssh

  def initialize(ssh, logger: $stdout)
    super()
    @ssh = ssh
    @logger = logger
  end

  def run(cmd)
    execute_ssh_command(cmd)
  end

  def run_script(location)
    script = ERB.new(File.read("scripts/#{location}")).result(binding)
    execute_ssh_command(script, log: true)
  end

  def upload_file(file, content, perms, group: nil)
    temp_file = "/tmp/#{File.basename(file)}"
    run("sudo rm -f #{temp_file}")
    Net::SFTP.start(@ssh.host, 'xavier') do |sftp|
      sftp.file.open(temp_file, "w", 600) do |f|
        f.write(content)
      end
    end
    run("sudo mkdir -p $(dirname #{file})")
    run("sudo mv #{temp_file} #{file}")
    run("sudo chmod #{perms} #{file}") if perms
    run("sudo chgrp #{group} #{file}") if group
  end

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
    @logger.puts data
  end
end
