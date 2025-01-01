class Context
  def initialize
    @vars = {}
  end

  def store_variable(key, value)
    @vars[key] = value
  end

  def read_variable(key)
    @vars.fetch(key)
  end

  alias_method :v, :read_variable
end
