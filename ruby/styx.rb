require 'babs'

class Styx < Babs
  task 'influxdb: install' do
    met? { run("influxd version").start_with?("InfluxDB v2.7.11") }
    meet {
      run_script("install_influxdb.bash")
    }
  end

  task 'influxdb: run' do
    met? { run("influx ping").start_with?("OK") }
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
        bucket = buckets.find {|x| x.fetch('name') == bucket_name }
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
    deps = permissions.values.flatten.map {|x| 'ensure influx token: %s' % x }
    task "ensure influxdb token: #{description}", depends: deps do
      met? {
        tokens = JSON.parse(run("influx auth list --json"))
        token = tokens.find {|x| x.fetch('description') == description }
        if token
          store_variable "#{description}.influxdb.api_token", token.fetch('token')
        end
      }
      meet {
        flags = []
        pp permissions
        flags << permissions.fetch(:read, []).map {|x|
          "--read-bucket %s" % read_variable("influxdb.buckets.#{x}")
        }
        flags << permissions.fetch(:write, []).map {|x|
          "--write-bucket" % read_variable("influxdb.buckets.#{x}")
        }
        run("influx auth create --description \"%s\" %s" % [
          description,
          flags.join(" ")
        ])
      }
    end
  end

  task 'telegraf: install' do
    met? { run("telegraf --version").start_with?("Telegraf 1.33.0") }
    meet {
      run_script("install_telegraf.bash")
    }
  end

  sftp_task 'telegraf: configure', [
    '/etc/telegraf/telegraf.conf'
  ], depends: 'ensure influxdb token: telegraf'

  task 'telegraf: run' do
    met? { run("systemctl is-active --quiet telegraf && echo OK").start_with?("OK") }
    meet {
      run("sudo systemctl restart telegraf")
    }
  end

  task 'telegraf', depends: [
    'telegraf: install',
    'telegraf: configure',
    'telegraf: run'
  ]

  variables \
    'influxdb.port' => 8086,
    'telegraf.influxdb.bucket' => 'system'

  root_task [
    'influxdb',
    'telegraf'
  ]
end

Styx.new.plan