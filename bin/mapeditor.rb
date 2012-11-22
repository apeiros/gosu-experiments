#!/usr/bin/env ruby
# encoding: utf-8

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'gui'
require 'map'
require 'rectangle'
require 'point'

class GameWindow < Gosu::Window
  Scale             = 1
  TileSize          = 16
  WidthPx           = 960
  HeightPx          = 720
  WidthT            = WidthPx/TileSize
  HeightT           = HeightPx/TileSize
  Highlight         = Gosu::Color.argb(0x99ffff00)
  BrushFillColor    = Gosu::Color.argb(0x99ffffff)
  BrushBorderColor  = Gosu::Color.argb(0xccffffff)

  def initialize
    super(WidthPx, HeightPx, false)
    self.caption = "Map Editor"

    @tiles          = tiles('overworld_tiles.png', TileSize, TileSize)
    @brushes        = image('overworld_tiles.png')
    @brushe_sizes   = [image('brush1x1.png'), image('brush3x3.png'), image('brush5x5.png')]
    @map            = File.exist?('map.txt') ? Map.load('map') : Map.filled(128, 128, 1)
    @last_column    = (WidthPx-160).div(TileSize)
    @selected_tile  = 1
    @brush_size     = 0
    @posx           = 0
    @posy           = 0
  end

  def needs_cursor?
    true
  end

  def update
    close if button_down?(KbEscape)
    if button_down?(KbReturn) || button_down?(KbEnter)
      @map.save('data/maps/autosave')
      @map.save(Time.now.strftime('%Y%m%d%H%M%S')+'_autosave')
    end
    if button_down? KbUp
      @posy -= 1
      @posy = 0 if @posy < 0
    elsif button_down? KbRight
      @posx += 1
      @posx = @map.width-WidthT+10 if @posx > @map.width-WidthT+10
    elsif button_down? KbDown
      @posy += 1
      @posy = @map.height-HeightT if @posy > @map.height-HeightT
    elsif button_down? KbLeft
      @posx -= 1
      @posx = 0 if @posx < 0
    end
    @tx = mouse_x.div(16)
    @ty = mouse_y.div(16)

    if button_down? MsLeft
      tx = @tx
      ty = @ty
      if tx >= @last_column
        tx -= @last_column
        tile = ty*10+tx
        if ty <= 9
          @selected_tile = tile if @map.valid_tile?(tile)
        elsif ty == 10 && tx <= 2
          @brush_size = tx
        end
      else
        tx += @posx
        ty += @posy
        coords = case @brush_size
          when 0 then [tx,ty]
          when 1 then [tx-1,ty-1,tx,ty-1,tx+1,ty-1, tx-1,ty,tx,ty,tx+1,ty, tx-1,ty+1,tx,ty+1,tx+1,ty+1]
          when 2 then (ty-2).upto(ty+2).flat_map { |y| (tx-2).upto(tx+2).flat_map { |x| [x,y] } }
        end
        coords.each_slice(2) do |x,y|
          @map[x,y] = @selected_tile if @map.xy_on_map?(x,y)
        end
      end
    end
  end

  def draw
    draw_rect(0,0,WidthPx,HeightPx,Color::WHITE,0)
    @brushes.draw(WidthPx-160, 0, 2)
    @brushe_sizes[0].draw(WidthPx-160, 160, 2)
    @brushe_sizes[1].draw(WidthPx-160+16, 160, 2)
    @brushe_sizes[2].draw(WidthPx-160+32, 160, 2)
    ty,tx = @selected_tile.divmod(10)
    draw_rect(WidthPx-160+(@brush_size*TileSize), 160, WidthPx-160+(@brush_size*TileSize)+TileSize, 160+TileSize, Highlight, 3)
    draw_rect(WidthPx-160+(tx*TileSize), (ty*TileSize), WidthPx-160+(tx*TileSize)+TileSize, (ty*TileSize)+TileSize, Highlight, 3)
    posxt = @posx*TileSize
    posyt = @posy*TileSize
    @map.clipped_each_tile(@posx, @posy, WidthT-10, HeightT) do |x,y,tile|
      @tiles[tile].draw((x-@posx)*TileSize, (y-@posy)*TileSize, 1)
    end
    if @tx < @last_column
      tx1 = @tx-@brush_size
      ty1 = @ty-@brush_size
      tx2 = @tx+@brush_size+1
      ty2 = @ty+@brush_size+1
      draw_rect_and_border(tx1*TileSize,ty1*TileSize,tx2*TileSize-1,ty2*TileSize-1,2,BrushFillColor, BrushBorderColor,5)
    end
  end
end

window = GameWindow.new
window.show
