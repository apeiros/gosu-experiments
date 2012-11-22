#!/usr/bin/env ruby
# encoding: utf-8

abort("USAGE: #{$0} OLD_FILE OUT_FILE") unless ARGV.size == 2



$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'map'



TileMapping   = Hash.new { |h,k| raise "Unknown tile: #{k.inspect}" }.merge({
  '.' => 10,
  '~' => 75,
  'x' => 31,
  '#' => 41,
  ' ' => 20,
  '=' => 72,
  '|' =>  0,
})

tiles = File.read(ARGV.first).split(/\n/).map { |line|
  line.chars.map { |char| TileMapping[char] }
}
map     = Map.new(tiles, {})
map.save(ARGV[1])
