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