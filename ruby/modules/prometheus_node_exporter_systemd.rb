class Tasks
  task 'prometheus node exporter systemd: install' do
    met? { run("prometheus-node-exporter --version || true").include?("version 1.5.0") }
    meet { run_root("apt install prometheus-node-exporter -y") }
  end

  task 'prometheus node exporter systemd: run', &run_task('prometheus-node-exporter')
  task 'prometheus node exporter systemd: enable', &enable_task('prometheus-node-exporter')

  task 'prometheus node exporter systemd', depends: [
    'prometheus node exporter systemd: install',
    'prometheus node exporter systemd: run',
    'prometheus node exporter systemd: enable'
  ]
end