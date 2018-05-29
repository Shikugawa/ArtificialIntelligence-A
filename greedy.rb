class Point
  attr_accessor :x, :y

  def initialize x, y
    @x = x
    @y = y
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
      Point.new(19, 15),
      Point.new(18, 15),
      Point.new(17, 15),
      Point.new(16, 15),
      Point.new(15, 15),
      Point.new(14, 15),
      Point.new(14, 16),
      Point.new(14, 17),
      Point.new(14, 18),
    ]
    @limit = Point.new(20, 20)
    @goal = Point.new(5, 0)
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
      place: [@field.current.x, @field.current.y],
      heuristic: heuristic(@field.current.x, @field.current.y)
    }

    while true
      if @open_list.length == 0
        puts "失敗"
        break
      end

      best_state = fetch()
      best_state_x = best_state[:place][0]
      best_state_y = best_state[:place][1]

      if is_goal? best_state
        puts "成功"
        break
      end

      children = [
        {
          place: [best_state_x+1, best_state_y],
          heuristic: heuristic(best_state_x+1, best_state_y)
        },
        {
          place: [best_state_x, best_state_y+1],
          heuristic: heuristic(best_state_x, best_state_y+1)
        },
        {
          place: [best_state_x-1, best_state_y],
          heuristic: heuristic(best_state_x-1, best_state_y)
        },
        {
          place: [best_state_x, best_state_y-1],
          heuristic: heuristic(best_state_x, best_state_y-1)
        }
      ]

      children.delete_if{ |child| is_wall?(child) }

      visualize best_state
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
    # p field
    field[best_state[:place][0]][best_state[:place][1]] = "X"
    # ゴール場所の可視化
    field[@field.goal.x][@field.goal.y] = "G"

    # 壁の場所の可視化
    @field.wall.each do |wall|
      field[wall.x][wall.y] = 1
    end

    @closed_list.each do |close|
      field[close[:place][0]][close[:place][1]] = "*"
    end

    # if options[:open_list]
      @open_list.each do |close|
        field[close[:place][0]][close[:place][1]] = "+"
      end
    # end

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
    (x - @field.goal.x).abs + (y - @field.goal.y).abs
  end

  def is_wall? state
    point = Point.new(state[:place][0], state[:place][1])
    wall_x = @field.wall.map{ |wall| wall.x }
    wall_y = @field.wall.map{ |wall| wall.y }

    (wall_x.include?(point.x) && wall_y.include?(point.y)) || point.x < 0 ||
    point.x >= @field.limit.x || point.y < 0 || point.y >= @field.limit.y
  end

  def is_goal? state
    state[:place][0] == @field.goal.x && state[:place][1] == @field.goal.y
  end
end

require "benchmark"
result = Benchmark.realtime do
  g = GreedySearch.new()
  g.search()
end

puts "処理概要 #{result}s"
