# encoding: utf-8

require 'point'

class Rectangle
  attr_reader :x, :y, :max_x, :max_y, :width, :height

  def initialize(x, y, width, height)
    @x      = x
    @y      = y
    @max_x  = x+width-1
    @max_y  = y+height-1
    @width  = width
    @height = height
  end

  def move_left(amount)
    @x -= amount

    self
  end

  def move_right(amount)
    @x += amount

    self
  end

  def move_up(amount)
    @y -= amount

    self
  end

  def move_down(amount)
    @y += amount

    self
  end

  def move(by_x, by_y)
    @x += by_x
    @y += by_y

    self
  end

  def each_x(&block)
    @x.upto(@max_x, &block)
  end

  def each_y(&block)
    @y.upto(@max_y, &block)
  end

  def top_left
    @top_left ||= Position.new(@x, @y)
  end

  def top_right
    @top_right ||= Position.new(@max_x, @y)
  end

  def bottom_left
    @bottom_left ||= Position.new(@x, @max_y)
  end

  def bottom_right
    @bottom_right ||= Position.new(@max_x, @max_y)
  end

  def within?(rect)
    top_left.within?(rect) && bottom_right.within?(rect)
  end

  def contains?(point_or_rect)
    point_or_rect.within?(self)
  end

  def contains_xy?(x, y)
    @x <= x && x <= @max_x && @y <= y && y <= @max_y
  end

  def to_a
    [@x, @y, @width, @height]
  end

  def to_h
    {x: @x, y: @y, width: @width, height: @height}
  end
end
