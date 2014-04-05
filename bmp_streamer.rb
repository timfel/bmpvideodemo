$LOAD_PATH.unshift(File.expand_path("../lib", __FILE__))
require "bmp_image"
require "raw_video_encoder"
require "sdl"

input = ARGV[0]
quality = (ARGV[1] || "50").to_i
sdl = SDL.new
screen = sdl.setvideomode(640, 480, 24, SDL::DOUBLEBUF)
pixels = sdl.get_pixels screen

unless input
  puts "$0 input_folder [quality]\n"
  puts "    0 < quality <= 100"
  exit
end

bmps = Dir["#{File.expand_path(input)}/*.bmp"].sort[0..-1].map do |file|
  BMPImage.new(file)
end
raise "No bitmaps found in #{input}" if bmps.size == 0

coder = RawRgbVideoEncoder.new(pixels, bmps, quality)
while (k = sdl.get_event) != 0
  coder.encode { sdl.flip screen }
  sdl.delay 10
end
