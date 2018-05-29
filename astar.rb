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

class AStarSearch
  def initialize
    @field = Field.new
    @open_list = []
    @closed_list = []
  end

  # h: ゴールと現在地の距離、f: ヒューリスティック関数
  def search
    @open_list << {
      prev: Point.new(nil, nil),
      place: Point.new(@field.current.x, @field.current.y),
      h: distance(@field.current, @field.goal),
      f: 0
    }

    while true
      if @open_list.length == 0
        puts "失敗"
        break
      end

      best_state = fetch()

      if is_goal? best_state
        puts "成功"
        break
      end

      children = [
        {
          prev: best_state[:place],
          place: Point.new(best_state[:place].x + 1, best_state[:place].y),
          h: distance(Point.new(best_state[:place].x + 1, best_state[:place].y), @field.goal),
          f: 0
        },
        {
          prev: best_state[:place],
          place: Point.new(best_state[:place].x, best_state[:place].y + 1),
          h: distance(Point.new(best_state[:place].x, best_state[:place].y + 1), @field.goal),
          f: 0
        },
        {
          prev: best_state[:place],
          place: Point.new(best_state[:place].x - 1, best_state[:place].y),
          h: distance(Point.new(best_state[:place].x - 1, best_state[:place].y), @field.goal),
          f: 0
        },
        {
          prev: best_state[:place],
          place: Point.new(best_state[:place].x, best_state[:place].y - 1),
          h: distance(Point.new(best_state[:place].x, best_state[:place].y - 1), @field.goal),
          f: 0
        }
      ]

      children.delete_if{ |child| is_wall?(child) }
      @closed_list << best_state

      children.each do |child|
        open_dup = @open_list.find{ |item|
          item[:place].get_point_array == child[:place].get_point_array
        }

        if open_dup
          if astar_heuristic(best_state, open_dup, child) < open_dup[:f]
            open_dup[:f] = astar_heuristic(best_state, open_dup, child)
            open_dup[:prev] = best_state[:place]
          end
        else
          closed_dup = @closed_list.find{ |item|
            item[:place].get_point_array == child[:place].get_point_array
          }

          if closed_dup
            if astar_heuristic(best_state, closed_dup, child) < closed_dup[:f]
              closed_dup[:f] = astar_heuristic(best_state, closed_dup, child)
              closed_dup[:prev] = best_state[:place]
              @open_list << closed_dup
              @closed_list.delete(closed_dup)
            end
          else
            child[:f] = astar_heuristic(best_state, child, child)
            @open_list << child
          end
        end
      end

      @open_list.uniq!
      visualize(best_state)
    end
  end

  def visualize current, options = {open_list: false}
    field = []
    @field.limit.x.times do |row|
      ary = []
      @field.limit.y.times do |col|
        ary << 0
      end
      field << ary
    end

    field[current[:place].x][current[:place].y] = "X"
    field[@field.goal.x][@field.goal.y] = "G"

    @field.wall.each do |wall|
      field[wall.x][wall.y] = 1
    end

    @closed_list.each do |close|
      field[close[:place].x][close[:place].y] = "*"
    end

    @open_list.each do |close|
      field[close[:place].x][close[:place].y] = "+"
    end

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
        elem_a[:f] <=> elem_b[:f]
      }.reverse!
      @open_list.pop
    else
      @open_list.shift
    end
  end

  def distance a, b
    Math.sqrt((a.x - b.x)**2 + (a.y - b.y)**2)
  end

  def astar_heuristic best_state, dup, child
    h = dup[:h]
    g = best_state[:f] - best_state[:h]
    cost = distance(best_state[:place], child[:place])

    return h + g + cost
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
  a = AStarSearch.new()
  a.search()
end

puts "処理概要 #{result}s"
