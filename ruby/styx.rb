require 'babs'

class Styx < Babs
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

  variables \
    'hostname' => 'styx',
    'influxdb.host' => 'influxdb.home',
    'influxdb.port' => 8086,
    'influxdb.org' => 'styx',
    'grafana.port' => 3000,
    'blocky.port' => 4000,
    'influxdb.password' => secret('influxdb_password'),
    'grafana.password' => secret('grafana_password'),
    'telegraf.influxdb.bucket' => 'system',
    'awair.host' => 'awair.home',
    'awair.influxdb.bucket' => 'sensors',
    'aws.buckets.backup' => 'xaviershay-backups', # TODO: From terraform
    'aws.infra_alerts_sns_topic_arn' => 'arn:aws:sns:ap-southeast-4:615749242856:infra-alerts', # TODO: Fetch from terraform
    'aws.region' => 'ap-southeast-4', # Melbourne
    'aws.access_key_id' => secret('aws_access_key_id'),
    'aws.secret_access_key' => secret('aws_secret_access_key')

  root_task [
    'system',
    'influxdb',
    'telegraf',
    'grafana',
    'blocky',
    'nginx',
    'awair'
  ]
end

Dir['modules/*.rb'].each do |f|
  require_relative f
end

args = ARGV.dup
meet = !args.delete("--no-meet")

Net::SSH.start('styx.local', 'xavier') do |ssh|
  Styx.new(meet: meet).apply(SSHContext.new(ssh), filter: args[0].to_s)
end
