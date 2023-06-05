require 'matrix'
require 'digest'

# Ruby version of Visicon
# Adapted from https://github.com/mozillazg/random-avatar/blob/master/avatar/utils/visicon/__init__.py

class Visicon
  def initialize(str, seed, size=24)
    @hash = Digest::MD5.hexdigest(str + seed)
    @size = size

    @block_one = @hash[0].to_i(16)
    @block_two = @hash[1].to_i(16)
    @block_centre = @hash[2].to_i(16) & 7
    @rotate_one = @hash[3].to_i(16) & 3
    @rotate_two = @hash[4].to_i(16) & 3
    @fg_colour = [
      @hash[5...7].to_i(16) & 239,
      @hash[7...9].to_i(16) & 239,
      @hash[9...11].to_i(16) & 239,
    ]
    @fg_colour2 = [
      @hash[11...13].to_i(16) & 239,
      @hash[13...15].to_i(16) & 239,
      @hash[15...17].to_i(16) & 239,
    ]

    @img_size = @size * 3
    @quarter = @size / 4
    @quarter3 = @quarter * 3
    @half = @size / 2
    @double = @size * 2
    @centre = @img_size / 2

    @commands = []
  end

  def draw_image
    Tempfile.create(['', '.png']) do |tmpfile|
      MiniMagick::Tool::Convert.new do |img|
        img.size "#{@img_size}x#{@img_size}"
        img.xc 'white'
        img << tmpfile.path
      end
      img = MiniMagick::Image.open(tmpfile.path)
      img.combine_options do |c|
        draw_corners(c)
        draw_sides(c)
        draw_centre(c)
      end
      img
    end
  end

 private

  def draw_corners(c)
    corners = [[0, 0], [0, @double], [@double, @double], [@double, 0]]
    corners.each_with_index { |corner, n|
      draw_outer_glyph(c, @block_one, @rotate_one + n, corner, @fg_colour)
    }
  end

  def draw_centre(c)
    draw_glyph(c, @block_centre, 0, [@size, @size], @fg_colour)
  end

  def draw_sides(c)
    sides = [[@size, 0], [0, @size], [@size, @double], [@double, @size]]
    sides.each_with_index { |side, n|
      draw_outer_glyph(c, @block_two, @rotate_two + n, side, @fg_colour2)
    }
  end

  def draw_outer_glyph(c, block, rotation, modifier, colour)
    gen_polygon = -> (pts) { rotated_polygon(c, pts, rotation, modifier, colour) }
    case block
    when 1
      gen_polygon.call [[0, 0], [@quarter, @size], [@half, 0]]
      gen_polygon.call [[@half, 0], [@quarter3, @size], [@size, 0]]
    when 2
      gen_polygon.call [[0, 0], [@size, 0], [0, @size]]
    when 3
      gen_polygon.call [[0, 0], [@half, @size], [@size, 0]]
    when 4
      gen_polygon.call [[0, 0], [0, @size], [@half, @size], [@half, 0]]
    when 5
      gen_polygon.call [[@quarter, 0], [0, @half], [@quarter, @size], [@half, @half]]
    when 6
      gen_polygon.call [[0, 0], [@size, @half], [@size, @size], [@half, @size]]
    when 7
      gen_polygon.call [[0, 0], [@half, @size], [0, @size]]
    when 8
      gen_polygon.call [[0, 0], [@size, @half], [@half, @size]]
    when 9
      gen_polygon.call [[@quarter, @quarter], [@quarter3, @quarter], [@quarter, @quarter3]]
    when 10
      gen_polygon.call [[0, 0], [@half, 0], [@half, @half]]
      gen_polygon.call [[@half, @half], [@size, @half], [@size, @size]]
    when 11
      gen_polygon.call [[0, 0], [0, @half], [@half, @half], [@half, 0]]
    when 12
      gen_polygon.call [[0, @half], [@half, @size], [@size, @half]]
    when 13
      gen_polygon.call [[0, 0], [@half, @half], [@size, 0]]
    when 14
      gen_polygon.call [[@half, @half], [0, @half], [@half, @size]]
    when 15
      gen_polygon.call [[0, 0], [0, @half], [@half, 0]]
    else
      gen_polygon.call [[0, 0], [@half, @half], [@half, 0]]
    end
  end

  def draw_glyph(c, block, rotation, modifier, color)
    gen_polygon = -> (pts) { rotated_polygon(c, pts, rotation, modifier, color) }
    case block
    when 1
      c.fill "rgb(#{color[0]},#{color[1]},#{color[2]}"
      c.draw "circle #{@centre},#{@centre} #{@centre},#{@centre + @quarter3}"
    when 2
      gen_polygon.call [[@quarter, @quarter], [@quarter3, @quarter], [@quarter3, @quarter3], [@quarter, @quarter3]]
    when 3
      gen_polygon.call [[0, 0], [0, @size], [@size, @size], [@size, 0]]
    when 4
      gen_polygon.call [[@half, @quarter], [@quarter3, @half], [@half, @quarter3], [@quarter, @half]]
    when 5
      gen_polygon.call [[@half, 0], [0, @half], [@half, @size], [@size, @half]]
    end
  end

  def rotated_polygon(c, points, rotation, modifier, color)
    polygon(c, rotate_points(points, rotation, modifier), color)
  end

  def polygon(c, points, color)
    points_str = points.map{|x,y| "#{x},#{y}"}.join(' ')
    c.fill "rgb(#{color[0]},#{color[1]},#{color[2]}"
    c.draw "polygon #{points_str}"
  end

  @@rotate_mats = [
    Matrix[[1,0],[0,1]],
    Matrix[[0,1],[-1,0]],
    Matrix[[-1,0],[0,-1]],
    Matrix[[0,-1],[1,0]]]
  @@offsets = [Vector[0,0], Vector[0,1], Vector[1,1], Vector[1,0]]

  def rotate_points(points, rotation, modifier)
    mat = @@rotate_mats[rotation % 4]
    offset = @@offsets[rotation % 4] * @size + Vector.elements(modifier)
    points.map {|pt| (mat * Vector.elements(pt) + offset).to_a}
  end
end