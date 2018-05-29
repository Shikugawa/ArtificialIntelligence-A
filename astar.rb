class Field
  attr_reader :current, :wall, :limit, :goal

  def initialize
    @current = [19, 19]
    @wall = [
      [7, 1],
      [7, 2],
      [7, 3],
      [7, 4],
      [7, 5],
      [7, 6],
      [6, 6],
      [5, 6],
      [4, 6],
      [3, 6],
    ]
    @limit = [20, 20]
    @goal = [3, 3]
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
      prev: [nil, nil],
      place: [@field.current[0], @field.current[1]],
      h: distance(@field.current, @field.goal),
      f: distance(@field.current, @field.goal)
    }

    # 30.times do
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
          place: [best_state[:place][0] + 1, best_state[:place][1]],
          h: distance([best_state[:place][0] + 1, best_state[:place][1]], @field.goal),
          f: nil
        },
        {
          prev: best_state[:place],
          place: [best_state[:place][0], best_state[:place][1] + 1],
          h: distance([best_state[:place][0], best_state[:place][1] + 1], @field.goal),
          f: nil
        },
        {
          prev: best_state[:place],
          place: [best_state[:place][0] - 1, best_state[:place][1]],
          h: distance([best_state[:place][0] - 1, best_state[:place][1]], @field.goal),
          f: nil
        },
        {
          prev: best_state[:place],
          place: [best_state[:place][0], best_state[:place][1] - 1],
          h: distance([best_state[:place][0], best_state[:place][1] - 1], @field.goal),
          f: nil
        }
      ]

      children.delete_if{ |child| is_wall?(child) }
      @closed_list << best_state

      children.each do |child|
        dist = distance(best_state[:place], child[:place])
        g = best_state[:f] - best_state[:h]
        f_pred = dist + g + child[:h]

        open_dup = @open_list.find{ |item|
          item[:place] == child[:place]
        }
        if open_dup
          if f_pred < open_dup[:f]
            @open_list.delete(open_dup)
            open_dup[:f] = f_pred
            open_dup[:prev] = best_state[:place]
            @open_list << open_dup
          end
        else
          closed_dup = @closed_list.find{ |item|
            item[:place] == child[:place]
          }

          if closed_dup
            if f_pred < closed_dup[:f]
              closed_dup[:f] = f_pred
              closed_dup[:prev] = best_state[:place]
              @open_list << closed_dup
              @closed_list.delete(closed_dup)
            end
          else
            child[:f] = f_pred
            child[:prev] = best_state[:place]
            @open_list << child
          end
        end
      end

      # 重複削除
      @open_list.uniq!
      visualize(best_state)
    end
  end

  def visualize options = {open_list: false}
    field = []

    @field.limit[0].times do |row|
      ary = []
      @field.limit[1].times do |col|
        ary << 0
      end
      field << ary
    end

    field[@field.goal[0]][@field.goal[1]] = "G"

    @field.wall.each do |wall|
      field[wall[0]][wall[1]] = 1
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
        elem_a[:f] <=> elem_b[:f]
      }.reverse!
      @open_list.pop
    else
      @open_list.shift
    end
  end

  def distance a, b
    Math.sqrt((a[0] - b[0])**2 + (a[1] - b[1])**2)
  end

  def astar_heuristic best_state, dup, child
    h = dup[:h]
    g = best_state[:f] - best_state[:h]
    cost = distance(best_state[:place], child[:place])

    return h + g + cost
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
result = Benchmark.realtime do
  a = AStarSearch.new()
  a.search()
end

puts @open_list
puts "処理概要 #{result}s"
