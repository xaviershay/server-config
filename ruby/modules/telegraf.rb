class Styx
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
end