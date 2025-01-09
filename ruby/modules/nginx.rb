class Styx
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
end