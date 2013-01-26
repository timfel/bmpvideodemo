
module QualityControl
  include Cassowary

  FrameRate = 12
  FrameTime = 1.0 / FrameRate
  LoadAvg = File.open("/proc/loadavg", "r")
  UserPref = File.open(File.expand_path("../../quality.pref", __FILE__), "r+")

  def self.extended(base)
    base.instance_eval do
      @user_preference = 100
      @cpuload = 0
      @duration = FrameTime
    end
  end

  def read_cpu_load
    LoadAvg.rewind
    @cpuload = LoadAvg.read(4).gsub(".", "").to_i
  end

  def read_user_preference
    input = UserPref.read
    if input and input.size > 0
      UserPref.truncate 0
      @user_preference = input.to_i
    end
  end

  def read_system_stats
    read_cpu_load
    read_user_preference
  end

  def cpuload
    @cpuload
  end

  def user_preference
    @user_preference
  end

  def duration
    @duration
  end

  def quality_control
    read_system_stats
    start = Time.now.to_f
    yield
    @duration = Time.now.to_f - start
    @quality = recalculate_quality
  end

  require "libcassowary"
  def recalculate_quality
    var_quality = Variable.new(value: @quality)
    solver = SimplexSolver.instance

    solver.add_constraint(var_quality <= 100)
    solver.add_constraint(var_quality > 0)
    solver.add_constraint(var_quality <= user_preference)
    solver.add_constraint(var_quality / 100 <= 80 / cpuload)
    solver.add_constraint(var_quality / 100 <= FrameTime / 0.9 / duration)
    solver.add_constraint((var_quality / 100).>=(FrameTime / 1.2 / duration, Strength::MediumStrength))

    solver.solve
    @quality = var_quality.value.to_i
  end
end
