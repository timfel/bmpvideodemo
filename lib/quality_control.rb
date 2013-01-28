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

      always { @quality >= 0 }
      always { @quality <= 100 }
      always(:strong) { @quality <= user_preference }
      always(:medium) { @quality == user_preference }
      always { @quality / 100 <= 80 / cpuload }
      always { @quality / 100 <= FrameTime / 1.2 / duration }
      always(:weak) { @quality / 100 >= FrameTime / 0.9 / duration }
    end
  end

  def read_cpu_load
    LoadAvg.rewind
    load = LoadAvg.read(4).gsub(".", "")
    if load.to_i != @cpuload
      @prev_load.disable if @prev_load
      @prev_load = always { @cpuload == load.to_i }
    end
  end

  def read_user_preference
    input = UserPref.read
    if input and input.size > 0
      UserPref.seek 0, File::SEEK_SET
      @prev_pref.disable if @prev_pref
      @prev_pref = always { @user_preference == input.to_i }
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
    @prev_duration.disable if @prev_duration
    @prev_duration = always { @duration == Time.now.to_f - start.value }
  end
end
