# encoding: utf-8

require 'yaml'
require 'rectangle'
require 'set'

class Map
  ValidTiles = [*0..47, *50..57, *60..66, *70..76, *80..86, 90, 91].to_set
  TileSize   = 16

  def self.load(path)
    meta_file    = path+".yaml"
    width, *tiles = File.read(path+".txt", encoding: Encoding::BINARY).unpack("NC*")
    tiles = tiles.map { |i| i-32 }.each_slice(width).to_a
    meta  = File.exist?(meta_file) ? YAML.load_file(meta_file) : {}

    new(tiles, meta)
  end

  def self.filled(width, height, tile, meta={})
    new(Array.new(width*height, tile).each_slice(width).to_a, meta)
  end

  attr_reader :width, :height, :tiles, :meta, :size

  def initialize(tiles, meta)
    @width  = tiles.first.size
    @height = tiles.size
    @tiles  = tiles
    @meta   = meta
    @size   = Rectangle.new(0, 0, @width, @height)
  end

  def []=(x,y,tile)
    @tiles[y][x] = tile
  end

  def at_point(point)
    @tiles.at(point.y).at(point.x)
  end

  def valid_tile?(tile)
    ValidTiles.include?(tile)
  end

  def xy_on_map?(x, y)
    @size.contains_xy?(x, y)
  end

  def point_on_map?(point)
    @size.contains?(point)
  end

  def each_tile
    return enum_for(__method__) unless block_given?

    @tiles.each_with_index do |row, y|
      row.each_with_index do |tile, x|
        yield(x, y, tile)
      end
    end
  end

  def each_tile_within(rectangle, &block)
    clipped_each_tile(rectangle.x, rectangle.y, rectangle.width, rectangle.height, &block)
  end

  def clipped_each_tile(from_x, from_y, width, height)
    return enum_for(__method__, from_x, from_y, width, height) unless block_given?
    #p clipped_each_tile: [from_x, from_y, width, height], map: @size

    from_y.upto(from_y+height-1) do |y|
      row = @tiles.at(y)
      from_x.upto(from_x+width-1) do |x|
        yield(x, y, row.at(x))
      end
    end
  end

  def binary
    ([@width]+@tiles.flatten.map { |i| i+32 }).pack("NC*")
  end

  def save(to_path)
    File.write(to_path+".txt", binary)
    File.write(to_path+".yaml", @meta.to_yaml)
  end
end
