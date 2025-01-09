class Styx
  sftp_task 'aws cli: configure', [
    '/home/xavier/.aws/config',
    '/home/xavier/.aws/credentials'
  ], 600

  task 'aws cli: install' do
    met? { run("aws --version || true").start_with?("aws-cli/2.9.19") }
    meet {
      run("sudo apt install awscli -y")
    }
  end

  task 'aws cli', depends: [
    'aws cli: install',
    'aws cli: configure'
  ]
end