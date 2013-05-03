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

  def assign_constraint_value(val)
    raise NotImplementedError("cannot store into timer (attempted to store #{val})")
  end

  def constraint_interpretation(name)
    __constrain__ { @time }
  end
end
