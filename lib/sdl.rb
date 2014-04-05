require "ffi"

class SDL
  extend FFI::Library

  ffi_lib "SDL"

  attach_function :SDL_Init, [:uint32], :int
  attach_function :SDL_SetVideoMode, [:int, :int, :int, :uint32], :pointer

  DOUBLEBUF   = 0x40000000
  INIT_VIDEO  = 0x00000020

  attach_function :SDL_Flip, [:pointer], :int
  attach_function :SDL_Delay, [:uint32], :void

  ffi_lib "./libsdlpixels.so"

  attach_function :SDL_get_pixels, [:pointer], :pointer
  attach_function :SDL_get_event, [], :int

  def self.new
    @instance ||= allocate
  end

  def initialize
    fail unless init(INIT_VIDEO) == 0
  end

  def draw_pixels(w, h, d, data)
    fail unless screen = setvideomode(w, h, d, DOUBLEBUF)
    pixels = get_pixels screen
    data.each_byte.each_with_index do |char, i|
      pixels.put_int8(i, char)
    end
    flip(screen)
  end

  self.methods.each do |m|
    if m.to_s.start_with?("SDL_")
      define_method m["SDL_".size..-1] do |*args|
        SDL.send(m, *args)
      end
      define_method m["SDL_".size..-1].downcase do |*args|
        SDL.send(m, *args)
      end
    end
  end
end
