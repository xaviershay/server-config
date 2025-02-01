class Tasks
  task 'prometheus: install' do
    met? { run("prometheus --version || true").include?("version 2.53.2") }
    meet { run("doas apk add prometheus") }
  end

  sftp_task 'prometheus: configure', [
    '/etc/prometheus/prometheus.yml'
  ], 644,
    after_meet: ->{
      run("doas rc-service prometheus restart")
    }

  task 'prometheus: run', &run_task('prometheus')
  task 'prometheus: enable', &enable_task('prometheus')

  task 'prometheus', depends: [
    'prometheus: install',
    'prometheus: configure',
    'prometheus: run',
    'prometheus: enable'
  ]
end