class Tasks
  task 'prometheus node exporter openrc: install' do
    met? { run("node_exporter --version || true").include?("version 1.8.2") }
    meet { run("doas apk add prometheus-node-exporter") }
  end

  task 'prometheus node exporter openrc: run', &run_task('node-exporter')
  task 'prometheus node exporter openrc: enable', &enable_task('node-exporter')

  task 'prometheus node exporter openrc', depends: [
    'prometheus node exporter openrc: install',
    'prometheus node exporter openrc: run',
    'prometheus node exporter openrc: enable'
  ]
end