# encoding: utf-8

require 'gosu'
require 'point'
require 'rectangle'

class Gosu::Window
  include Gosu

  def read_data(path)
    File.read("data/#{path}")
  end

  def tiles(name, w, h, tileable=true)
    Image.load_tiles(self, "media/#{name}", w, h, tileable)
  end

  def image(name, *args)
    if args.length == 5
      tileable = args.shift
    else
      tileable = true
    end
    Image.new(self, "media/#{name}", tileable, *args)
  end

  def draw_rect(ax,ay,bx,by,c, z)
    draw_quad(ax,ay,c, bx,ay,c, ax,by,c, bx,by,c, z)
  end

  def draw_border(ax,ay, bx,by, width, c, z)
    draw_rect(ax,ay,bx,ay+width,c, z) # top
    draw_rect(ax,by-width,bx,by,c, z) # bottom
    draw_rect(ax,ay+width,ax+width,by-width,c, z) # left
    draw_rect(bx-width,ay+width,bx,by-width,c, z) # right
  end

  def draw_rect_and_border(ax,ay, bx,by, width, fill_color, border_color, z)
    draw_rect(ax+width,ay+width,bx-width,by-width,fill_color,z)
    draw_border(ax,ay, bx,by, width, border_color, z)
  end
end
