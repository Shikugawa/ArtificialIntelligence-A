class AStarSearch
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
      prev: [nil, nil],
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
          prev: [best_state_x, best_state_y],
          place: [best_state_x+1, best_state_y],
          heuristic: astar_heuristic(best_state_x, best_state_y,
                                     best_state_x+1, best_state_y)
        },
        {
          prev: [best_state_x, best_state_y],
          place: [best_state_x, best_state_y+1],
          heuristic: astar_heuristic(best_state_x, best_state_y,
                               best_state_x, best_state_y+1)
        },
        {
          prev: [best_state_x, best_state_y],
          place: [best_state_x-1, best_state_y],
          heuristic: astar_heuristic(best_state_x, best_state_y,
                               best_state_x-1, best_state_y)
        },
        {
          prev: [best_state_x, best_state_y],
          place: [best_state_x, best_state_y-1],
          heuristic: astar_heuristic(best_state_x, best_state_y,
                               best_state_x, best_state_y-1)
        }
      ]

      children.delete_if{ |child| is_wall?(child) }
      @closed_list << best_state

      # 子ノードの集合からclosedに含まれないn'に対してopenに追加
      children.each do |child|
        if @closed_list.select{ |closed| closed[:place] == child[:place] }.length == 0
          @open_list << child
        end
      end

      # open_listの中で、placeが同じであり、よりコストが小さいものをopen_listに残し、残りを削除
      refined = []
      grouped = @open_list.group_by{ |data| data[:place] }
      grouped.each do |key, value|
        value.sort!{ |elem_a, elem_b|
          elem_a[:heuristic] <=> elem_b[:heuristic]
        }
        refined << value[0]
      end
      @open_list = refined

      # open_list中のplaceで、closed_listに含まれるplaceと一致するものを抽出し、closed_listに含まれるもののコストがより
      # 小さいならば、closed_listからそれを削除しopen_listに加える。コストが大きかったほうはopen_listから消える
      grouped = @closed_list.group_by{ |data| data[:place] }
      @open_list.inject([]) {|ary, value|
        ary << value if grouped.keys.include? value[:place]
        ary
      }.each do |repetition|
        min_heuristic = grouped[repetition[:place]]
                        .each_with_index.inject do |min, (close, index)|
          min = close if index == 0 || close[:heuristic] < repetition[:heuristic]
          min
        end
        @open_list << min_heuristic
        @closed_list.delete(min_heuristic)
        @open_list.delete_if{ |value|
          value[:place] == min_heuristic[:place] && value[:heuristic] > min_heuristic[:place]
        }
      end

      @open_list.uniq!

      # visualize()
    end
  end

  def visualize options = {open_list: true}
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
    h = (x - @goal[0]) + (y - @goal[1])
    g = (@current_x - x) + (@current_y - y)

    (h+g).abs
  end

  def astar_heuristic prev_x, prev_y, x, y
    h = ((x - @goal[0]) + (y - @goal[1])).abs
    g = ((prev_x - @current_x) + (prev_y - @current_y)).abs
    c = ((x - prev_x) + (y - prev_y)).abs

    return h + g + c
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
  a = AStarSearch.new()
  a.search()
  a.visualize({
    open_list: true
  })
end

puts "処理概要 #{result}s"
