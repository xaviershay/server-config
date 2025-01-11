require 'babs'

class Styx < Babs
  def self.systemctl_enable_task(service)
    ->{ met? { raise("Host does not support systemctl") } }
  end

  def self.systemctl_run_task(service)
    ->{ met? { raise("Host does not support systemctl") } }
  end

  def self.apt_package(name)
    ->{
      met? { run("dpkg -s #{name} | grep Status || true").include?("ok") }
      meet { run("sudo apt-get install #{name} -y") }
    }
  end

  def self.github_task(repo)
    name = repo.split('/').last

    dir = "~/code/#{name}"
    ->{
      met? { !run("test -f #{dir}/README.md || echo NO").include?("NO") }
      meet do
        run("rm -r #{dir}")
        run("mkdir -p #{dir}")
        run("git clone git@github.com:#{repo}.git #{dir}")
      end
    }
  end

  REPOS = %w(
    blog-v2
    server-config
  )

  sftp_task 'ssh', '/home/xavier/.ssh/known_hosts', 644

  repo_tasks = REPOS.map do |name|
    repo = "xaviershay/#{name}"
    "github: #{repo}".tap do |task_name|
      task task_name, depends: 'ssh', &github_task(repo)
    end
  end

  %w(make wget).each do |package|
    task "apt: #{package}", &apt_package(package)
  end

  task 'dev: ruby', depends: ['apt: wget', 'apt: make'] do
    met? { run("~/.rubies/ruby-3.4.1/bin/ruby -v || true").include?("ruby 3.4.1") }
    meet do
      run_script("dev_ruby.bash")
    end
  end

  task 'dev: terraform', depends: ['apt: wget'] do
    met? { run("terraform -v || true").include?("Terraform v1.10.4") }
    meet do
      run_script("dev_terraform.bash")
    end
  end

  root_task [
    'dev: ruby',
    'dev: terraform',
    'sshd: configure'
  ] + repo_tasks
end

Dir['modules/*.rb'].each do |f|
  require_relative f
end

args = ARGV.dup
meet = !args.delete("--no-meet")

Net::SSH.start('apollo.local', 'xavier') do |ssh|
  Styx.new(meet: meet).apply(SSHContext.new(ssh), filter: args[0].to_s)
end