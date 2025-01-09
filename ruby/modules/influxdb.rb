class Styx
  task 'influxdb: install' do
    met? { run("influxd version || true").start_with?("InfluxDB v2.7.11") }
    meet {
      run_script("install_influxdb.bash")
    }
  end

  sftp_task 'influxdb: configure', '/etc/influxdb2/config.yml', 644,
    after_meet: ->{ run("sudo systemctl restart influxdb") }

  sftp_task 'influxdb: configure backup', [
    '/usr/local/bin/backup-influxdb',
    '/etc/cron.d/cron.daily/run-backup-influxdb'
  ], 755, depends: 'aws cli'


  task 'influxdb: setup', depends: 'influxdb: install' do
    met? { run("influx server-config") rescue false }
    meet {
      run_script("setup_influxdb.bash")
    }
  end

  task 'influxdb: enable', &systemctl_enable_task('influxdb')
  task 'influxdb: run', &systemctl_run_task('influxdb')

  task 'influxdb', depends: [
    'influxdb: install',
    'influxdb: configure',
    'influxdb: configure backup',
    'influxdb: run',
    'influxdb: setup',
    'influxdb: enable'
  ]

  %w(system sensors).each do |bucket_name|
    task "ensure influxdb bucket: #{bucket_name}", depends: 'influxdb' do
      met? {
        buckets = JSON.parse(run("influx bucket list --json"))
        bucket = buckets.find {|x| x.fetch('name') == bucket_name.to_s }
        if bucket
          store_variable "influxdb.buckets.#{bucket_name}", bucket.fetch('id')
          true
        else
          false
        end
      }
      meet {
        run("influx bucket create --name %s" % [
          bucket_name,
        ])
      }
    end
  end

  {
    grafana: {read: ['system', 'sensors']},
    telegraf: {write: ['system']},
    awair: {write: ['sensors']}
  }.each do |description, permissions|
    deps = permissions.values.flatten.map {|x| 'ensure influxdb bucket: %s' % x }
    task "ensure influxdb token: #{description}", depends: deps do
      met? {
        tokens = JSON.parse(run("influx auth list --json"))
        token = tokens.find {|x| x.fetch('description') == description.to_s }
        if token
          store_variable "#{description}.influxdb.api_token", token.fetch('token')
          true
        else
          false
        end
      }
      meet {
        flags = []
        flags << permissions.fetch(:read, []).map {|x|
          "--read-bucket %s" % read_variable("influxdb.buckets.#{x}")
        }
        flags << permissions.fetch(:write, []).map {|x|
          "--write-bucket %s" % read_variable("influxdb.buckets.#{x}")
        }
        run("influx auth create --description \"%s\" %s" % [
          description,
          flags.join(" ")
        ])
      }
    end
  end
end