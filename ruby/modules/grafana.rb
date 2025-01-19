class Tasks
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
    '/etc/grafana/dashboards/host-health.json',
    '/etc/grafana/dashboards/air-quality.json',
    '/etc/grafana/dashboards/air-quality-mobile.json',
  ], 640,
   group: 'grafana',
   depends: 'ensure influxdb token: grafana',
   after_meet: ->{ run("sudo systemctl restart grafana-server") }

  task 'grafana: enable', &systemctl_enable_task('grafana-server')
  task 'grafana: run', &systemctl_run_task('grafana-server')

  task 'grafana', depends: [
    'grafana: install',
    'grafana: configure',
    'grafana: run',
    'grafana: enable'
  ]
end