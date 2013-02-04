require "libcassowary"

class Point
  def x
    @x
  end

  def y
    @y
  end

  def x=(num)
    @x = num
  end

  def y=(num)
    @y = num
  end

  def initialize(x, y)
    @x = x
    @y = y
    always { @x >= 0 }
    always { @y >= 0 }
    always { @x < 640 }
    always { @y < 480 }
  end

  def to_s
    "#{@x}@#{@y}"
  end
  alias inspect to_s
end

class HorizontalLine
  def start
    @start
  end

  def end
    @end
  end

  def initialize(pt1, pt2)
    @start = pt1
    @end = pt2
    always { pt1.y == pt2.y }
  end

  def length
    @end.x - @start.x
  end

  def to_s
    "line from: #{@start.inspect} to: #{@end.inspect} (length: #{length})"
  end
  alias inspect to_s
end

h = HorizontalLine.new(Point.new(1, 1), Point.new(2, 2))
puts h
always { h.length >= 100 }
puts h
h.start.y = 199
puts h
h.start.y = 10_000
puts h
