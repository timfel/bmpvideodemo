class MethodTimer
  def initialize(klass, symbol)
    time = 0
    _start = Time.now
    _end = Time.now
    always { time == (_end - _start) * 1000 }
    @constrainted_time = __constrain__ { time }

    old_method = klass.instance_method(symbol)
    klass.define_method(symbol) do |*args, &block|
      _start = Time.now
      res = old_method.bind(self).call(*args, &block)
      _end = Time.now
      res
    end
  end

  def time
    @constrainted_time.value
  end

  def assign_constraint_value(float)
    raise "cannot assign to timer" if float != time
  end

  def for_constraint(name)
    @constrainted_time
  end
end
