class Styx
  task 'cloudflared: install' do
    met? { run("cloudflared --version || true").include?("2025.1.0") }
    meet {
      run_script("install_cloudflared.bash")
    }
  end

  sftp_task 'cloudflared: configure', [
    '/etc/systemd/system/cloudflared.service'
  ], 600,
    after_meet: ->{ run("sudo systemctl restart cloudflared") }

  task 'cloudflared: enable', &systemctl_enable_task('cloudflared')
  task 'cloudflared: run', &systemctl_run_task('cloudflared')

  task 'cloudflared', depends: [
    'cloudflared: install',
    'cloudflared: configure',
    'cloudflared: enable',
    'cloudflared: run'
  ]
end