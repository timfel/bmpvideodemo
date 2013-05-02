class MethodTimer
  def initialize(klass, symbol)
    @time = 0

    old_method = klass.instance_method(symbol)
    klass.define_method(symbol) do |*args, &block|
      start = Time.now.to_f
      res = old_method.bind(self).call(*args, &block)
      @time = (Time.now.to_f - start) * 1000
      puts @time
      res
    end
  end

  def last_time
    @time
  end

  def for_constraint(name)
    @constraint_variable = last_time.for_constraint(name)
  end
end
