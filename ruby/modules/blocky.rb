class Tasks
  task 'blocky: install' do
    met? { run("blocky version | grep Version || true").start_with?("Version: v0.24") }
    meet {
      run_script("install_blocky.bash")
    }
  end

  sftp_task 'blocky: configure', [
    '/usr/local/etc/blocky/config.yml',
    '/etc/systemd/system/blocky.service'
  ], 644,
    after_meet: ->{ run("sudo systemctl restart blocky") }

  task 'blocky: enable', &systemctl_enable_task('blocky')
  task 'blocky: run', &systemctl_run_task('blocky')

  task 'blocky', depends: [
    'blocky: install',
    'blocky: configure',
    'blocky: run',
    'blocky: enable'
  ]
end