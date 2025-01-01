require 'babs'

class Styx < Babs
  task 'influxdb: install' do
    met? { run("influxd version || true").start_with?("InfluxDB v2.7.11") }
    meet {
      run_script("install_influxdb.bash")
    }
  end

  task 'influxdb: run' do
    met? { run("influx ping || true").start_with?("OK") }
    meet {
      run("sudo systemctl restart influxdb")
    }
  end

  sftp_task 'influxdb: configure', '/etc/influxdb2/config.yml', 644,
    after_meet: ->{ run("sudo systemctl restart influxdb") }

  task 'influxdb: setup', depends: 'influxdb: install' do
    met? { run("influx server-config") rescue false }
    meet {
      run_script("setup_influxdb.bash")
    }
  end
  task 'influxdb', depends: [
    'influxdb: install',
    'influxdb: configure',
    'influxdb: run',
    'influxdb: setup',
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
    telegraf: {write: ['system']}
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

  task 'telegraf: install' do
    met? { run("telegraf --version").start_with?("Telegraf 1.33.0") }
    meet {
      run_script("install_telegraf.bash")
    }
  end

  sftp_task 'telegraf: configure', '/etc/telegraf/telegraf.conf', 640,
   depends: 'ensure influxdb token: telegraf',
   group: 'telegraf',
   after_meet: ->{ run("sudo systemctl restart telegraf") }

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

  task 'grafana: install' do
    met? { run("/usr/sbin/grafana-server --version || true").start_with?("Version 11.4.0") }
    meet {
      run_script("install_grafana.bash")
    }
  end

  sftp_task 'grafana: configure', [
    '/etc/grafana/grafana.ini',
    '/etc/grafana/provisioning/datasources/influxdb.yml',
    '/etc/grafana/provisioning/dashboards/default.yml',
    '/etc/grafana/dashboards/host-health.json'
  ], 640,
   group: 'grafana',
   depends: 'ensure influxdb token: grafana',
   after_meet: ->{ run("sudo systemctl restart grafana-server") }

  task 'grafana: run' do
    met? { run("systemctl is-active --quiet grafana-server && echo OK").start_with?("OK") }
    meet {
      run("sudo systemctl restart grafana-server")
    }
  end

  task 'grafana', depends: [
    'grafana: install',
    'grafana: configure',
    'grafana: run'
  ]

  task 'hostname' do
    met? {
      @name = read_variable 'hostname'
      run("hostname") == @name
    }
    meet { run("sudo hostnamectl set-hostname #{@name}") }
  end

  sftp_task 'motd', [
    '/etc/motd', # Blank file, only use dynamic generation
    '/etc/update-motd.d/10-uname',
    '/etc/update-motd.d/20-styx'
  ], 755
  sftp_task 'hosts', '/etc/hosts', 644
  sftp_task 'ssh', '/etc/ssh/sshd_config', 644

  variables \
    'hostname' => 'styx',
    'influxdb.port' => 8086,
    'influxdb.password' => secret('influxdb_password'),
    'grafana.port' => 3000,
    'grafana.password' => secret('grafana_password'),
    'telegraf.influxdb.bucket' => 'system'

  task 'system', depends: [
    'hostname',
    'hosts',
    'motd',
    'ssh'
  ]

  root_task [
    'system',
    'influxdb',
    'telegraf',
    'grafana'
  ]
end

Styx.new.apply
