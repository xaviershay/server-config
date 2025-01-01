class Context
  def initialize
    @vars = {}
  end

  def store_variable(key, value)
    @vars[key] = value
  end

  def read_variable(key)
    x = @vars.fetch(key)
    if x.respond_to?(:call)
      x.call
    else
      x
    end
  end

  alias_method :v, :read_variable
end
