class GreedySearch
  def initialize
    @current_x = 24
    @current_y = 23
    @wall_x = [3, 4, 5, 6, 7, 12, 25, 31, 24, 28, 15, 13].freeze
    @wall_y = [2, 3, 6, 7, 8, 2, 6, 3, 5, 2, 3, 5].freeze
    @x_limit = 32
    @y_limit = 32
    @goal = [5, 0].freeze
    @open_list = []
    @closed_list = []
  end

  def search
    @open_list << {
      place: [@current_x, @current_y],
      heuristic: heuristic(@current_x, @current_y)
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
      # p children
      children.delete_if{ |child| is_wall?(child) }

      @closed_list << best_state
      @open_list += children.delete_if{ |child| @closed_list.include? child }
      @open_list.uniq!

      # puts " "
      # visualize
      # p @open_list
      # puts " "
    end
  end

  def visualize options = {open_list: false}
    field = []
    @x_limit.times do |row|
      ary = []
      @y_limit.times do |col|
        ary << 0
      end
      field << ary
    end

    # ゴール場所の可視化
    field[@goal[0]][@goal[1]] = "G"

    # 壁の場所の可視化
    @wall_x.each do |x|
      @wall_y.each{ |y| field[x][y] = 1 }
    end

    @closed_list.each do |close|
      field[close[:place][0]][close[:place][1]] = "*"
    end

    if options[:open_list]
      @open_list.each do |close|
        field[close[:place][0]][close[:place][1]] = "+"
      end
    end

    field.each do |f|
      f.each { |elem| print elem.to_s + " " }
      print "\n"
    end
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
    (x - @goal[0]).abs + (y - @goal[1]).abs
  end

  def is_wall? state
    x = state[:place][0]
    y = state[:place][1]

    (@wall_x.include?(x) && @wall_y.include?(y)) ||
    x < 0 || x >= @x_limit || y < 0 || y >= @y_limit
  end

  def is_goal? state
    state[:place][0] == @goal[0] && state[:place][1] == @goal[1]
  end
end

require "benchmark"
result = Benchmark.realtime do
  g = GreedySearch.new()
  g.search()
  g.visualize({
    open_list: true
  })
end

puts "処理概要 #{result}s"
