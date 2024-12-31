require 'net/ssh'

require 'context'
require 'set'

class TaskDefinition
  def met?(*args, &block)
    @met = block
  end

  def meet(*args, &block)
    @meet = block
  end

  def _met; @met end
  def _meet; @meet end
end

TaskSpec = Data.define(:name, :depends, :block)

class Babs
  # Progress until a met? is not met then halt
  def plan
    Net::SSH.start('styx.local') do |ssh|
      @completed = Set.new
      @context = Context.new(ssh)
      root = self.class.root
      root.each do |task_name|
        run_task(task_name)
      end
    end
  end

  def run_task(task_name)
    return if @completed.include?(task_name)

    puts task_name
    task = self.class.tasks.fetch(task_name)
    task.depends.each do |dep|
      run_task(dep)
    end
    if task.block
      t = TaskDefinition.new
      t.instance_exec(&task.block)

      met = @context.instance_exec(&t._met)
      unless met
        @context.instance_exec(&t._meet)
        met = @context.instance_exec(&t._met)
        unless met
          raise "task not met after meeting: #{task_name}"
        end
      end
    end
    @completed << task.name
  end

  # Progress fully
  def apply
  end

  def self.root; @root end
  def self.tasks; @tasks end

  def self.root_task(deps)
    @root = deps
  end

  def self.task(name, depends: [], &block)
    @tasks ||= {}
    @tasks[name] = TaskSpec.new(
      name,
      [*depends],
      block
    )
  end

  def self.sftp_task(name, file, depends: [], &block)
    # TODO
    @tasks ||= {}
    @tasks[name] = TaskSpec.new(
      name,
      [*depends],
      block
    )
  end
end