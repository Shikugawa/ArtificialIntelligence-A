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

class AStarSearch
  attr_reader :field, :closed_list

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

        open_dup = @open_list.lazy.find{ |item|
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
          closed_dup = @closed_list.lazy.find{ |item|
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
      @field.field_map_state << visualize(best_state)
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


    @open_list.each do |close|
      field[close[:place][0]][close[:place][1]] = "+"
    end

    return field
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

a = AStarSearch.new()
result = Benchmark.realtime do
  a.search()
end

a.field.field_map_state.each_with_index do |state, index|
  if index % 5 == 0 || a.field.field_map_state.length == index + 1
    puts "#{index}回の試行"
    state.each do |f|
      f.each { |elem| print elem.to_s + " " }
      print "\n"
    end
    puts "\n"
  end
end

field = a.field.generate_field do |f|
  a.closed_list.inject([]){ |ary, item|
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

puts "処理時間 #{result}s"
