require "libcassowary"
require "iosolver"
require "method_timer"

class RawRgbVideoEncoder
  FrameMsMax = 1000 / 50
  NumberOfProcessors = `nproc`.strip.to_i
  @@userpref = FloatRwIO.new(File.expand_path("../../quality.pref", __FILE__), "r+")
  @@loadavg = FloatRwIO.new("/proc/loadavg", "r")

  def initialize(io, frames, quality)
    @frames = frames
    @io = io
    @quality = quality

    always { @quality >= 0 }
    always { @quality <= 100 }
    always { @quality <= user_preference }
    always(:strong) { @quality == user_preference }
    always { @quality + cpuload * 100 <= 100 + 80 * NumberOfProcessors }
    always(:strong) { @quality + encoding_time >= 90 }
    always { @quality + encoding_time <= 100 + FrameMsMax }
  end

  def encode
    # p "Encoding time: #{encoding_time.time}"
    # p "Pref: #{user_preference.content.strip}"
    # p "Load: #{cpuload.content.strip}"
    # p "Quality: #{@quality}"
    @frames.each do |frame|
      # XXX: this should happen in a thread
      user_preference.refresh
      cpuload.refresh
      encode_frame(frame)
    end
  end

  def encode_frame(frame)
    skip = (frame.height / 64 * ((100 - @quality).to_f / 100.0)).to_i
    skip = 1 if skip < 1
    y = 0
    buf = ""

    while y + skip < frame.height
      line = ""
      x = 0
      pos = y * frame.width

      while x + skip < frame.width
        line << frame.rpixel_at(pos) * skip
        x += skip
        pos += skip
      end
      line << frame.rpixel_at(pos) * (frame.width - x)
      buf << line * skip
      y += skip
    end
    buf << line * (frame.height - y)

    @io << buf
  end
  @@timer = MethodTimer.new(self, :encode_frame)

  def encoding_time
    @@timer
  end

  def user_preference
    @@userpref
  end

  def cpuload
    @@loadavg
  end
end
