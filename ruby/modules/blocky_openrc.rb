class Tasks
  task 'blocky openrc: install' do
    met? { run("blocky version | grep Version || true").start_with?("Version: 0.24") }
    meet { run("doas apk add blocky") }
  end

  sftp_task 'blocky openrc: configure', [
    '/etc/blocky/config.yml'
  ], 644,
    after_meet: ->{
      run("doas /etc/init.d/blocky restart")
    }

  task 'blocky openrc: enable', &enable_task('blocky')
  task 'blocky openrc: run', &run_task('blocky')

  task 'blocky openrc', depends: [
    'blocky openrc: install',
    'blocky openrc: configure',
    'blocky openrc: run',
    'blocky openrc: enable'
  ]
end