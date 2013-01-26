require "libcassowary"

module QualityControl
  FrameRate = 12
  FrameTime = 1.0 / FrameRate
  LoadAvg = File.open("/proc/loadavg", "r")
  UserPref = File.open(File.expand_path("../../quality.pref", __FILE__), "r+")

  def self.extended(base)
    base.instance_eval do
      @quality = 100
      @user_preference = 100
      @cpuload = 1
      @duration = FrameTime

      constrain { @quality >= 0 }
      constrain { @quality <= 100 }
      constrain { @quality <= user_preference }
      constrain { @quality / 100 >= FrameTime / 1.2 / duration }
      constrain { @quality / 100 <= FrameTime / 0.9 / duration }
      constrain { @quality / 100 <= 80 / cpuload }
    end
  end

  def read_cpu_load
    LoadAvg.rewind
    load = LoadAvg.read(4).gsub(".", "").to_i
    if load != @cpuload
      @cpuload = load
    end
  end

  def read_user_preference
    input = UserPref.read
    if input and input.size > 0 and input.to_i != @user_preference
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
  end
end
