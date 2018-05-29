class Point
  attr_accessor :x, :y

  def initialize x, y
    @x = x
    @y = y
  end

  def get_point_array
    [@x, @y]
  end
end

class Field
  attr_reader :current, :wall, :limit, :goal

  def initialize
    @current = Point.new(19, 19)
    @wall = [
      Point.new(7, 1),
      Point.new(7, 2),
      Point.new(7, 3),
      Point.new(7, 4),
      Point.new(7, 5),
      Point.new(7, 6),
      Point.new(6, 6),
      Point.new(5, 6),
      Point.new(4, 6),
      Point.new(3, 6),
      Point.new(18, 13),
      Point.new(17, 13),
      Point.new(16, 13),
      Point.new(15, 13),
      Point.new(14, 13),
      Point.new(13, 13),
      Point.new(13, 14),
      Point.new(13, 15),
      Point.new(13, 16),
      Point.new(13, 17)
    ]
    @limit = Point.new(20, 20)
    @goal = Point.new(3, 1)
  end
end

class GreedySearch
  def initialize
    @field = Field.new
    @open_list = []
    @closed_list = []
  end

  def search
    @open_list << {
      place: Point.new(@field.current.x, @field.current.y),
      heuristic: heuristic(@field.current.x, @field.current.y)
    }

    while true
    # 50.times do
      if @open_list.length == 0
        puts "失敗"
        break
      end

      best_state = fetch()
      best_state_x = best_state[:place].x
      best_state_y = best_state[:place].y

      if is_goal? best_state
        puts "成功"
        break
      end

      children = [
        {
          place: Point.new(best_state_x+1, best_state_y),
          heuristic: heuristic(best_state_x+1, best_state_y)
        },
        {
          place: Point.new(best_state_x, best_state_y+1),
          heuristic: heuristic(best_state_x, best_state_y+1)
        },
        {
          place: Point.new(best_state_x-1, best_state_y),
          heuristic: heuristic(best_state_x-1, best_state_y)
        },
        {
          place: Point.new(best_state_x, best_state_y-1),
          heuristic: heuristic(best_state_x, best_state_y-1)
        }
      ]

      # p best_state
      visualize best_state
      # p children
      children.delete_if{ |child| is_wall?(child) }
      # p children
      @closed_list << best_state
      @open_list += children.delete_if{ |child| @closed_list.include? child }
      @open_list.uniq!
    end
  end

  def visualize best_state, options = {open_list: false}
    field = []

    @field.limit.x.times do |row|
      ary = []
      @field.limit.y.times do |col|
        ary << 0
      end
      field << ary
    end

    field[@field.goal.x][@field.goal.y] = "G"

    @field.wall.each do |wall|
      field[wall.x][wall.y] = 1
    end

    @closed_list.each do |close|
      field[close[:place].x][close[:place].y] = "*"
    end

    # if options[:open_list]
      @open_list.each do |close|
        field[close[:place].x][close[:place].y] = "+"
      end
    # end

    field[best_state[:place].x][best_state[:place].y] = "="
    field.each do |f|
      f.each { |elem| print elem.to_s + " " }
      print "\n"
    end

    puts "\n"
  end

  private
  def fetch
    if @open_list.length > 1
      @open_list.sort!{ |elem_a, elem_b|
        elem_a[:heuristic] <=> elem_b[:heuristic]
      }.reverse!
      @open_list.pop
    else
      @open_list.shift
    end
  end

  def heuristic x, y
    Math.sqrt((x - @field.goal.x)**2 + (y - @field.goal.y)**2)
  end

  def is_wall? state
    point = state[:place]
    wall_x = @field.wall.map{ |wall| wall.x }
    wall_y = @field.wall.map{ |wall| wall.y }
    wall_ary = wall_x.zip(wall_y)

    wall_ary.include?(point.get_point_array) || point.x < 0 ||
    point.x >= @field.limit.x || point.y < 0 || point.y >= @field.limit.y
  end

  def is_goal? state
    state[:place].get_point_array == @field.goal.get_point_array
  end
end

require "benchmark"
result = Benchmark.realtime do
  g = GreedySearch.new()
  g.search()
end

puts "処理概要 #{result}s"
