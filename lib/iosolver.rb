class FloatRwIO
  def initialize(filename, mode="r", *args, &block)
    @file = File.new(filename, mode, *args, &block)
    @writable = mode =~ /[+w]/
    @content = @file.read
    @file.rewind
  end

  def refresh
    @file.rewind
    @content = @file.read
  end

  def assign_constraint_value(float)
    if float != @content.to_f
      raise "cannot assign to read-only file" unless @writable
      @file.truncate(0)
      @file.rewind
      @file.write(float)
    end
  end

  def for_constraint(name)
    unless @constraint_variable
      @constraint_variable = 0
      if @writable
        always(:strong) { @constraint_variable == @content.to_f }
      else
        always { @constraint_variable == @content.to_f }
      end
    end
    __constrain__ { @constraint_variable }
  end
end

puts "IO constraint solver loaded."
