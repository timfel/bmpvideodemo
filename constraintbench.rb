require "libcassowary"

class Mercury
  def initialize
    @top = 10
    @bottom = 0
  end

  def top=(num)
    @top = num
  end

  def top
    @top
  end

  def bottom
    @bottom
  end

  def height
    @top - @bottom
  end

  def inspect
    "<Mercury: #{@top}->#{@bottom}>"
  end
end

class Mouse
  def initialize
    @location_y = 10
  end

  def location_y
    @location_y
  end

  def location_y=(arg)
    @location_y = arg
  end

  def inspect
    "<Mouse: #{@location_y}>"
  end
end

class Rectangle
  def initialize(name, top, bottom)
    @name = name
    @top = top
    @bottom = bottom
  end

  def top
    @top
  end

  def top=(arg)
    @top = arg
  end

  def bottom
    @bottom
  end

  def bottom=(arg)
    @bottom = arg
  end

  def inspect
    "<#{@name} Rectangle: #{@top}->#{@bottom}>"
  end
end

class Thermometer < Rectangle
  def initialize(top, bottom)
    super("thermometer", top, bottom)
  end

  def inspect
    "<Thermometer: #{@top}->#{@bottom}>"
  end
end

class Display
  def initialize
    @number = 0
  end

  def number
    @number
  end

  def number=(arg)
    @number = arg
  end

  def inspect
    "<Display: #{@number}>"
  end
end



Iterations = 100_000





def imperative
mouse = Mouse.new
mercury = Mercury.new
thermometer = Thermometer.new(200.0, 0.0)
grey = Rectangle.new("grey", mercury.top, mercury.bottom)
white = Rectangle.new("white", thermometer.top, mercury.top)
temperature = mercury.height
display = Display.new


start = Time.now
(0...Iterations).each do |i|
  mouse.location_y = i
  old = mercury.top
  mercury.top = mouse.location_y
  if mercury.top > thermometer.top
    mercury.top = thermometer.top
  end
  temperature = mercury.height
  if old < mercury.top
    # moves top upwards and thus draws over the white part
    grey.top = mercury.top
  else
    # moves bottom downwards and thus draws over the grey part
    white.bottom = mercury.top
  end
  display.number = temperature
  [mouse, mercury, thermometer, grey, white, temperature, display]
end
puts "Duration (#{Iterations} iterations): #{Time.now - start}"
puts [mouse, mercury, thermometer, grey, white, temperature, display].map { |e| e.inspect }
end





def library
mouse_location_y = Cassowary::Variable.new value: 10
mercury_top = Cassowary::Variable.new value: 10
mercury_bottom = Cassowary::Variable.new value: 0
mercury_height = mercury_top - mercury_bottom
thermometer_top = Cassowary::Variable.new value: 200
thermometer_bottom = Cassowary::Variable.new value: 0
grey_top = Cassowary::Variable.new value: mercury_top.value
grey_bottom = Cassowary::Variable.new value: mercury_bottom.value
white_top = Cassowary::Variable.new value: thermometer_top.value
white_bottom = Cassowary::Variable.new value: mercury_top.value
temperature = Cassowary::Variable.new value: mercury_height.value
display_number = Cassowary::Variable.new value: 0

solver = Cassowary::SimplexSolver.new
solver.auto_solve = false

solver.add_constraint temperature == mercury_height
solver.add_constraint white_top == thermometer_top
solver.add_constraint white_bottom == mercury_top
solver.add_constraint grey_top == mercury_top
solver.add_constraint grey_bottom == mercury_bottom
solver.add_constraint display_number == temperature
constraint = mercury_top == mouse_location_y
constraint.strength = Cassowary.symbolic_strength(:strong)
solver.add_constraint constraint
solver.add_constraint mercury_top <= thermometer_top
solver.add_constraint mercury_bottom == thermometer_bottom
solver.add_constraint thermometer_bottom == 0
solver.add_constraint thermometer_top == 200

solver.add_edit_var(mouse_location_y, Cassowary.symbolic_strength(:strong))
solver.solve
solver.begin_edit

start = Time.now
(0...Iterations).each do |i|
  solver.suggest_value(mouse_location_y, i)
  solver.resolve
end
solver.end_edit
puts "Duration (#{Iterations} iterations): #{Time.now - start}"
puts [mouse_location_y.value,
      "#{mercury_top.value}->#{mercury_bottom.value}",
      "#{thermometer_top.value}->#{thermometer_bottom.value}",
      "#{grey_top.value}->#{grey_bottom.value}",
      "#{white_top.value}->#{white_bottom.value}",
      temperature.value,
      display_number.value].map { |e| e.inspect }
end






def ocp
mouse = Mouse.new
mercury = Mercury.new
thermometer = Thermometer.new(200, 0)
grey = Rectangle.new("grey", mercury.top, mercury.bottom)
white = Rectangle.new("white", thermometer.top, mercury.top)
temperature = mercury.height
display = Display.new

always { temperature == mercury.height }
always { white.top == thermometer.top }
always { white.bottom == mercury.top }
always { grey.top == mercury.top }
always { grey.bottom == mercury.bottom }
always { display.number == temperature }
always(:strong) { mercury.top == mouse.location_y }
always { mercury.top <= thermometer.top }
always { mercury.bottom == thermometer.bottom }
always { thermometer.bottom == 0 }
always { thermometer.top == 200 }
start = Time.now
(0...Iterations).each do |i|
  mouse.location_y = i
#  [mouse, mercury, thermometer, grey, white, temperature, display]
end
puts "Duration (#{Iterations} iterations): #{Time.now - start}"
puts [mouse, mercury, thermometer, grey, white, temperature, display].map { |e| e.inspect }
end


def editvars
mouse = Mouse.new
mercury = Mercury.new
thermometer = Thermometer.new(200, 0)
grey = Rectangle.new("grey", mercury.top, mercury.bottom)
white = Rectangle.new("white", thermometer.top, mercury.top)
temperature = mercury.height
display = Display.new

always { temperature == mercury.height }
always { white.top == thermometer.top }
always { white.bottom == mercury.top }
always { grey.top == mercury.top }
always { grey.bottom == mercury.bottom }
always { display.number == temperature }
always(:strong) { mercury.top == mouse.location_y }
always { mercury.top <= thermometer.top }
always { mercury.bottom == thermometer.bottom }
always { thermometer.bottom == 0 }
always { thermometer.top == 200 }
start = Time.now

edit((0...Iterations).each) { mouse.location_y }
puts "Duration (#{Iterations} iterations): #{Time.now - start}"
puts [mouse, mercury, thermometer, grey, white, temperature, display].map { |e| e.inspect }
end


send(ARGV[0])
