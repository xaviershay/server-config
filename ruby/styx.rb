require 'babs'

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