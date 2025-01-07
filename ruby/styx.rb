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

  task 'influxdb: enable', &systemctl_enable_task('influxdb')

  task 'influxdb', depends: [
    'influxdb: install',
    'influxdb: configure',
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

  task 'telegraf: enable', &systemctl_enable_task('telegraf')

  task 'telegraf', depends: [
    'telegraf: install',
    'telegraf: configure',
    'telegraf: run',
    'telegraf: enable'
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

  task 'grafana: enable', &systemctl_enable_task('grafana-server')

  task 'grafana', depends: [
    'grafana: install',
    'grafana: configure',
    'grafana: run',
    'grafana: enable'
  ]

  task 'blocky: install' do
    met? { run("blocky version | grep Version || true").start_with?("Version: v0.24") }
    meet {
      run_script("install_blocky.bash")
    }
  end

  sftp_task 'blocky: configure', [
    '/etc/blocky/config.yml',
    '/etc/systemd/system/blocky.service'
  ], 644,
    after_meet: ->{ run("sudo systemctl restart blocky") }

  task 'blocky: run' do
    met? { run("systemctl is-active --quiet blocky && echo OK").start_with?("OK") }
    meet {
      run("sudo systemctl restart blocky")
    }
  end

  task 'blocky: enable', &systemctl_enable_task('blocky')

  task 'blocky', depends: [
    'blocky: install',
    'blocky: configure',
    'blocky: run',
    'blocky: enable'
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
  # Not sure why this executable, but matches what was there
  sftp_task 'boot_config', '/boot/firmware/config.txt', 755
  sftp_task 'sshd: configure', '/etc/ssh/sshd_config', 644
  task 'sshd: enable', &systemctl_enable_task('ssh')

  sftp_task 'aws cli: configure', [
    '/home/xavier/.aws/config',
    '/home/xavier/.aws/credentials'
  ], 600

  task 'aws cli: install' do
    met? { run("aws --version || true").start_with?("aws-cli/2.9.19") }
    meet {
      run("sudo apt install awscli")
    }
  end

  task 'aws cli', depends: [
    'aws cli: install',
    'aws cli: configure'
  ]

  task 'nginx: install' do
    met? { run("sudo nginx -version 2>&1 || true").include?("nginx/1.22.1") }
    meet {
      run("sudo apt install nginx -y")
    }
  end
  task 'nginx: enable', &systemctl_enable_task('nginx')
  task 'nginx: run' do
    met? { run("systemctl is-active --quiet nginx && echo OK").start_with?("OK") }
    meet {
      run("sudo systemctl restart nginx")
    }
  end
  sftp_task 'nginx: configure', '/etc/nginx/conf.d/reverse-proxy.conf', 644,
    after_meet: ->{ run("sudo nginx -s reload") }

  task 'nginx', depends: [
    'nginx: install',
    'nginx: configure',
    'nginx: run',
    'nginx: enable'
  ]

  sftp_task 'notify-on-fail', '/usr/local/bin/notify-on-fail', 755, depends: 'aws cli'
  sftp_task 'backup-influxdb', [
    '/usr/local/bin/backup-influxdb',
    '/etc/cron.d/cron.daily/run-backup-influxdb'
  ], 755, depends: 'aws cli'

  task 'ruby' do
    met? { run("ruby -v || true").include?("ruby 3.1.2") }
    meet {
      run("sudo apt install ruby -y")
    }
  end

  sftp_task 'awair: install', '/usr/local/bin/awair-to-influxdb', 755, depends: 'ruby'
  sftp_task 'awair: configure', [
    '/usr/local/etc/awair/config.yml',
    '/etc/systemd/system/awair.service'
  ], 644,
    depends: 'ensure influxdb token: awair',
    after_meet: ->{ run("sudo systemctl restart awair") }

  task 'awair: run' do
    met? { run("systemctl is-active --quiet awair && echo OK").start_with?("OK") }
    meet {
      run("sudo systemctl restart awair")
    }
  end

  task 'awair', depends: [
    'awair: install',
    'awair: configure',
    'awair: run'
  ]
  # TODO: Ruby apt install


  task 'blocky: enable', &systemctl_enable_task('blocky')

  variables \
    'hostname' => 'styx',
    'influxdb.host' => '192.168.1.2', # TODO: 'influxdb.home',
    'influxdb.port' => 8086,
    'influxdb.org' => 'styx',
    'grafana.port' => 3000,
    'blocky.port' => 4000,
    'influxdb.password' => secret('influxdb_password'),
    'grafana.password' => secret('grafana_password'),
    'telegraf.influxdb.bucket' => 'system',
    'awair.host' => '192.168.1.3', # TODO: 'awair.home',
    'awair.influxdb.bucket' => 'sensors',
    'aws.buckets.backup' => 'xaviershay-backups', # TODO: From terraform
    'aws.infra_alerts_sns_topic_arn' => 'arn:aws:sns:ap-southeast-4:615749242856:infra-alerts', # TODO: Fetch from terraform
    'aws.region' => 'ap-southeast-4', # Melbourne
    'aws.access_key_id' => secret('aws_access_key_id'),
    'aws.secret_access_key' => secret('aws_secret_access_key')

  task 'system', depends: [
    'hostname',
    'hosts',
    'motd',
    'boot_config',
    'notify-on-fail',
    'backup-influxdb',
    'sshd: configure',
    'sshd: enable'
  ]

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

Net::SSH.start('styx.local', 'xavier') do |ssh|
  Styx.new.apply(SSHContext.new(ssh), filter: ARGV[0].to_s)
end
