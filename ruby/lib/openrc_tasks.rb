module OpenrcTasks
  def enable_task(service)
    ->{
      met? { run("rc-update show | grep #{service} || true").include?(service) }
      meet { run("doas rc-update add #{service} default") }
    }
  end

  def run_task(service)
    ->{
      met? { run("rc-service #{service} status || true").include?("status: started") }
      meet { run("doas rc-service #{service} start") }
    }
  end
end