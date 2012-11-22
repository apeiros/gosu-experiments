#!/usr/bin/env ruby
# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'gui'
require 'set'
require 'map'

class GameWindow < Gosu::Window
  include Gosu

  Scale       = ARGV.first ? ARGV.first.to_i : 1
  TileSize    = 16#*Scale
  WidthPx     = 960
  HeightPx    = 720
  WidthT      = WidthPx/(TileSize*Scale)
  HeightT     = HeightPx/(TileSize*Scale)
  MaxXT       = WidthT-1
  MaxYT       = HeightT-1

  Walkable = [10, 20, 72, 0].to_set

  def initialize
    super(WidthPx, HeightPx, false)
    self.caption    = "Map Exploration Test"
    @map_tiles      = tiles('overworld_tiles.png', 16, 16)
    @hero_tiles     = [
      image('link.png',  0,0, 16, 16), # down
      image('link.png', 30,0, 16, 16), # left
      image('link.png', 60,0, 16, 16), # up
      image('link.png', 90,0, 16, 16), # right
    ]
    @map            = Map.load('data/maps/level_01')
    @screen_max_xt  = @map.width-WidthT
    @screen_max_yt  = @map.height-HeightT
    @screen         = Rectangle.new(65, 52, WidthT, HeightT)
    @hero_pos       = Point.new(97, 98)
    @hero_rel_pos   = @hero_pos.relative_to(@screen)
    @hero_direction = 0
  end

  def needs_cursor?
    true
  end

  def update
    if button_down? KbUp
      new_hero_pos    = @hero_pos.up
      @hero_direction = 2
    elsif button_down? KbRight
      new_hero_pos = @hero_pos.right
      @hero_direction = 3
    elsif button_down? KbDown
      new_hero_pos = @hero_pos.down
      @hero_direction = 0
    elsif button_down? KbLeft
      new_hero_pos = @hero_pos.left
      @hero_direction = 1
    elsif button_down? KbEscape
      exit
    else
      new_hero_pos = @hero_pos
    end
    if @map.point_on_map?(new_hero_pos) && Walkable.include?(@map.at_point(new_hero_pos))
      @hero_moved   = true
      @screen_moved = true
      @hero_pos     = new_hero_pos
      @hero_rel_pos = new_hero_pos.relative_to(@screen)

      #p rel_pos: @hero_rel_pos.to_h, screen: @screen.to_h, smxt: @screen_max_xt, smyt: @screen_max_yt

      if @hero_rel_pos.x < 8 && @screen.x > 0
        @screen = @screen.move_left([@screen.x, 16].min)
      elsif @hero_rel_pos.x > WidthT-8 && @screen.x < @screen_max_xt
        @screen = @screen.move_right([16, @screen_max_xt-@screen.x].min)
      elsif @hero_rel_pos.y < 5 && @screen.y > 0
        @screen = @screen.move_up([@screen.y, 9].min)
      elsif @hero_rel_pos.y > HeightT-5 && @screen.y < @screen_max_yt
        @screen = @screen.move_down([9, @screen_max_yt-@screen.y].min)
      else
        @screen_moved = false
      end
      @hero_rel_pos = new_hero_pos.relative_to(@screen) if @screen_moved

    else
      @hero_moved = false
    end
  end

  def draw
    scale(Scale, Scale, 0, 0) do
      @map.each_tile_within(@screen) do |x,y,tile|
        @map_tiles[tile].draw((x-@screen.x)*TileSize,(y-@screen.y)*TileSize, 0)
      end
      @hero_tiles[@hero_direction].draw(@hero_rel_pos.x*TileSize, @hero_rel_pos.y*TileSize, 1)
    end
  end
end

window = GameWindow.new
window.show
