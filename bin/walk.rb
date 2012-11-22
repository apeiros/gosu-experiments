#!/usr/bin/env ruby
# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'gui'
require 'set'

$fullscreen = false

class GameWindow < Gosu::Window
  Down  = 0
  Left  = 1
  Up    = 2
  Right = 3

  Scale = 2
  Size  = 16
  Dist  = 160*Scale
  Walk  = 1*Scale

  def initialize
    super(960, 720, $fullscreen, 25)
    self.caption = "Walking Test"
    @hero = [
      [image('link.png',  0, 0, Size,Size), image('link.png',  0,30, Size,Size)], # down
      [image('link.png', 30, 0, Size,Size), image('link.png', 31,30, Size,Size)], # left
      [image('link.png', 60, 0, Size,Size), image('link.png', 60,30, Size,Size)], # up
      [image('link.png', 90, 0, Size,Size), image('link.png', 90,30, Size,Size)], # right
      [image('link.png',  0, 0, Size,Size), image('link.png',  0, 0, Size,Size)], # down
      [image('link.png', 30, 0, Size,Size), image('link.png', 30, 0, Size,Size)], # left
      [image('link.png', 60, 0, Size,Size), image('link.png', 60, 0, Size,Size)], # up
      [image('link.png', 90,30, Size,Size), image('link.png', 90,30, Size,Size)], # right
    ]
    @iter   = 0
    @dir    = 3
    @walk   = false
    @x      = 0
    @y      = 0
  end

  def needs_cursor?
    true
  end

  def update
    close if button_down? KbEscape

    move  = true
    @walk = true
    if button_down? KbUp
      @dir  = Up
      move  = @y > 0
    elsif button_down? KbDown
      @dir  = Down
      move  = @y < (Dist-Size)
    elsif button_down? KbLeft
      @dir  = Left
      move  = @x > 0
    elsif button_down? KbRight
      @dir  = Right
      move  = @x < (Dist-Size)
    else
      @walk = false
      move  = false
    end

    if move
      case @dir
        when Right
          @x += Walk
        when Down
          @y += Walk
        when Left
          @x -= Walk
        when Up
          @y -= Walk
      end
    end
    @iter += 1
    @iter  = 0 if @iter > 7
  end

  def draw
    @hero[@dir+(@walk ? 0 : 4)][@iter.div(4)].draw(@x, @y, 0, Scale, Scale)
  end
end

window = GameWindow.new
window.show

__END__
    if @x == 0 && @y == 0
      @dir = Right
    elsif @x == 0 && @y == Dist
      @dir = Up
    elsif @x == Dist && @y == 0
      @dir = Down
    elsif @x == Dist && @y == Dist
      @dir = Left
    end


