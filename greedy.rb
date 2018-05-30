class Field
  attr_reader :current, :wall, :limit, :goal
  attr_accessor :field_map_state

  def initialize
    @field_map_state = []

    @current = [3, 3]
    @wall = [
      [11, 0], [11, 1], [11, 2], [11, 3],
      [11, 4], [11, 5], [11, 6], [11, 7],
      [11, 8], [11, 9], [11, 10], [11, 11],
      [10, 11], [9, 11], [8, 11], [7, 11],
      [13, 16], [14, 16], [15, 16], [16, 16],
      [16, 15], [16, 14], [16, 13]
    ]
    @limit = [20, 20]
    @goal = [19, 19]
  end

  def generate_field
    field = []

    @limit[0].times do |row|
      ary = []
      @limit[1].times do |col|
        ary << '-'
      end
      field << ary
    end

    field[@goal[0]][@goal[1]] = "G"

    @wall.each do |wall|
      field[wall[0]][wall[1]] = 1
    end

    yield(field) if block_given?
    return field
  end
end

class GreedySearch
  attr_reader :field, :closed_list

  def initialize
    @field = Field.new
    @open_list = []
    @closed_list = []
  end

  def search
    @open_list << {
      place: [@field.current[0], @field.current[1]],
      heuristic: heuristic(@field.current[0], @field.current[1])
    }

    while true
    # 50.times do
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
      @closed_list << best_state
      @open_list += children.delete_if{ |child| @closed_list.include? child }

      @field.field_map_state << visualize()
    end

    @field.field_map_state.each_with_index do |state, index|
      if index % 5 == 0 || @field.field_map_state.length == index + 1
        puts "#{index}回の試行"
        state.each do |f|
          f.each { |elem| print elem.to_s + " " }
          print "\n"
        end
        puts "\n"
      end
    end
  end

  def visualize options = {open_list: false}
    field = @field.generate_field do |f|
      @closed_list.each do |close|
        f[close[:place][0]][close[:place][1]] = "*"
      end

      @open_list.each do |close|
        f[close[:place][0]][close[:place][1]] = "+"
      end
    end
    return field
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
    Math.sqrt((x - @field.goal[0])**2 + (y - @field.goal[1])**2)
  end

  def is_wall? state
    point = state[:place]

    @field.wall.include?(point) || point[0] < 0 ||
    point[0] >= @field.limit[0] || point[1] < 0 || point[1] >= @field.limit[1]
  end

  def is_goal? state
    state[:place] == @field.goal
  end
end

require "benchmark"

g = GreedySearch.new()
result = Benchmark.realtime do
  g.search()
end

g.field.field_map_state.each_with_index do |state, index|
  if index % 5 == 0 || g.field.field_map_state.length == index + 1
    puts "#{index}回の試行"
    state.each do |f|
      f.each { |elem| print elem.to_s + " " }
      print "\n"
    end
    puts "\n"
  end
end

field = g.field.generate_field do |f|
  g.closed_list.inject([]){ |ary, item|
    ary << item[:place]
    ary
  }.each do |data|
    f[data[0]][data[1]] = "@"
  end
end

puts "=======ゴール探索経路======="
field.each do |f|
  f.each { |elem| print elem.to_s + " " }
  print "\n"
end

puts "処理概要 #{result}s"
