class Styx
  sftp_task 'motd', [
    '/etc/motd', # Blank file, only use dynamic generation
    '/etc/update-motd.d/10-uname',
    '/etc/update-motd.d/20-styx'
  ], 755
  sftp_task 'hosts', '/etc/hosts', 644
  sftp_task 'sshd: configure', '/etc/ssh/sshd_config', 644
  task 'sshd: enable', &systemctl_enable_task('ssh')

  task 'hostname' do
    met? {
      @name = read_variable 'hostname'
      run("hostname") == @name
    }
    meet { run("sudo hostnamectl set-hostname #{@name}") }
  end

  sftp_task 'notify-on-fail', '/usr/local/bin/notify-on-fail', 755, depends: 'aws cli'

  task 'ruby' do
    met? { run("ruby -v || true").include?("ruby 3.1.2") }
    meet {
      run("sudo apt install ruby -y")
    }
  end

  task 'system', depends: [
    'hostname',
    'hosts',
    'motd',
    'notify-on-fail',
    'sshd: configure',
    'sshd: enable'
  ]
end