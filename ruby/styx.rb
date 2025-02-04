require 'babs'

class Tasks < Babs
  def self.systemctl_enable_task(service)
    ->{
      met? {
        run(<<-CMD).start_with?("OK")
          sudo systemctl status #{service} \
            | grep Loaded \
            | grep -qv disabled \
            && echo "OK" \
            || true
        CMD
      }
      meet { run("sudo systemctl enable #{service}") }
    }
  end

  def self.systemctl_run_task(service)
    ->{
      met? { run("systemctl is-active --quiet #{service} && echo OK").start_with?("OK") }
      meet {
        run("sudo systemctl restart #{service}")
      }
    }
  end

  def self.run_task(service)
    systemctl_run_task(service)
  end

  def self.enable_task(service)
    systemctl_enable_task(service)
  end

  variables \
    'hostname' => 'styx',
    'influxdb.host' => 'influxdb.home',
    'influxdb.port' => 8086,
    'influxdb.org' => 'styx',
    'grafana.port' => 3000,
    'influxdb.password' => secret('influxdb_password'),
    'grafana.password' => secret('grafana_password'),
    'telegraf.influxdb.bucket' => 'system',
    'awair.host' => 'awair.home',
    'awair.influxdb.bucket' => 'sensors',
    'aws.buckets.backup' => 'xaviershay-backups', # TODO: From terraform
    'aws.infra_alerts_sns_topic_arn' => 'arn:aws:sns:ap-southeast-4:615749242856:infra-alerts', # TODO: Fetch from terraform
    'aws.region' => 'ap-southeast-4', # Melbourne
    'aws.access_key_id' => secret('aws_access_key_id'),
    'aws.secret_access_key' => secret('aws_secret_access_key'),
    'cloudflared.http_tunnel_id' => secret('cloudflared_http_tunnel_id'),
    'ipv6.stable_secret' => secret('apollo_ipv6_secret')

  # Fan settings
  # Not sure why this executable, but matches what was there
  sftp_task 'boot_config', '/boot/firmware/config.txt', 755

  task 'styx', depends: [
    'boot_config'
  ]

  root_task [
    'system',
    'influxdb',
    'telegraf',
    'grafana',
    'nginx',
    'awair',
    'cloudflared',
    'ipv6',
    'ipv6: NetworkManager',
    'prometheus node exporter systemd',
    'styx'
  ]
end

Dir['modules/*.rb'].each do |f|
  require_relative f
end

args = ARGV.dup
meet = !args.delete("--no-meet")

Net::SSH.start('styx.home', 'xavier') do |ssh|
  Tasks.new(meet: meet).apply(SSHContext.new(ssh), filter: args[0].to_s)
end
