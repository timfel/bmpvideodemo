require "libcassowary"
require "iosolver"

class RawRgbVideoEncoder
  FrameMsMax = 1000 / 50
  @@loadavg = File.open("/proc/loadavg", "r")
  @@userpref = File.open(File.expand_path("../../quality.pref", __FILE__), "r+")

  def initialize(io, frames, quality)
    @frames = frames
    @io = io
    @quality = quality

    always { @quality >= 0 }
    always { @quality <= 100 }
    always(:strong) { @quality <= user_preference }
    always(:medium) { @quality == user_preference }
    always { @quality <= 100 - cpuload * 125 + 100 } # 0.8 cpuload max => 0.8 * 125 = 100
    # always { @quality <= 100 - FrameMsMax * 5 + 100 } # 1000/50 == FrameTime max => 20 * 5 = 100
  end

  def encode(quality)
    @quality = quality

    @frames.each do |frame|
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

  def cpuload
    @@loadavg.read(4).gsub(".", "").to_i
  end

  def user_preference
    @@userpref.read.to_i
  end
end
