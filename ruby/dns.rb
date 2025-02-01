require 'babs'
require 'openrc_tasks'

class Tasks < Babs
  extend OpenrcTasks

  variables \
    'blocky.port' => 4000

  root_task [
    "blocky openrc",
    "prometheus node exporter openrc"
  ]
end

Dir['modules/*.rb'].each do |f|
  require_relative f
end

args = ARGV.dup
meet = !args.delete("--no-meet")

ips = [
  '192.168.1.11',
  '192.168.1.12',
]

ips.each do |ip|
  Net::SSH.start(ip, 'alpine') do |ssh|
    Tasks.new(meet: meet).apply(SSHContext.new(ssh, root_bin: 'doas'), filter: args[0].to_s)
  end
end