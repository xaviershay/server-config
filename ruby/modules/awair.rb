class Tasks
  sftp_task 'awair: install', '/usr/local/bin/awair-to-influxdb', 755, depends: 'ruby'
  sftp_task 'awair: configure', [
    '/usr/local/etc/awair/config.yml',
    '/etc/systemd/system/awair.service'
  ], 644,
    depends: 'ensure influxdb token: awair',
    after_meet: ->{ run("sudo systemctl restart awair") }

  task 'awair: run' do
    met? { run("(systemctl is-active --quiet awair && echo OK) || true").start_with?("OK") }
    meet {
      run("sudo systemctl restart awair")
    }
  end

  task 'awair', depends: [
    'awair: install',
    'awair: configure',
    'awair: run'
  ]
end