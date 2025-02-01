require 'babs'

class Tasks < Babs
  def self.enable_task(service)
    ->{
      met? { run("rc-update show | grep #{service} || true").include?(service) }
      meet { run("doas rc-update add #{service} default") }
    }
  end

  def self.run_task(service)
    ->{
      met? { run("rc-service #{service} status || true").include?("status: started") }
      meet { run("doas rc-service #{service} start") }
    }
  end

  root_task [
    "prometheus",
    "prometheus node exporter openrc"
  ]
end

Dir['modules/*.rb'].each do |f|
  require_relative f
end

args = ARGV.dup
meet = !args.delete("--no-meet")

ips = [
  '192.168.1.13'
]

ips.each do |ip|
  Net::SSH.start(ip, 'alpine') do |ssh|
    Tasks.new(meet: meet).apply(SSHContext.new(ssh, root_bin: 'doas'), filter: args[0].to_s)
  end
end