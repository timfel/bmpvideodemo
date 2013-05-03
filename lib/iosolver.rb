class FloatRwIO
  def initialize(*args, &block)
    @file = File.new(*args, &block)
    @ticker = Fiber.new do
      loop do
        refresh
        Fiber.yield
      end
    end
  end

  def content
    @file.rewind
    @file.read.to_f
  end

  def content=(float)
    raise NotImplementedError("cannot assign")
    # @file.truncate(0)
    # @file.write(float.to_s)
  end

  def refresh
    val = content
    c = always { @constraint_variable == val }
    c.disable
    # @constraint_variable = val
  end

  def assign_constraint_value(float)
    self.content = float
  end

  def for_constraint(name)
    @constraint_variable ||= content
    __constrain__ { @constraint_variable }
  end
end

puts "IO constraint solver loaded."
