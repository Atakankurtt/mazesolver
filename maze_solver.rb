require 'byebug'
require 'set'
class MazeSolver
    DELTAS = [
    [-1,  0],
    [ 0, -1],
    [ 0,  1],
    [ 1,  0]
    ].freeze

    attr_reader :maze, :start
    def initialize(filename)
        @maze = File.readlines(filename).map(&:chomp).map { |line| line.split("") }
        @start = find_coor("S")
        @end = find_coor("E")
        @open = [@start] # the set of nodes to be evaluated
        @close = { @start => nil } # the hash of nodes already evaluated
    end

    def find_coor(symbol) # To find start and end points.
        @maze.each_with_index do |line, i|
            return [i, line.index(symbol)] if line.include?(symbol)
        end
    end

    def get_neighbours(pos)
        neighbours = DELTAS.map do |(dx, dy)|
            [pos[0] + dx, pos[1] + dy]
        end.select do |x, y|
            @maze[x][y] != "*"
        end
    end

    def h_score(pos, a = @end) # Distance from end node
        x, y = pos
        e_x, e_y = a
        (x - e_x).abs + (y - e_y).abs
    end

    def g_score(pos) # Distance from starting node
        x, y = pos
        s_x, s_y = @start
        Math.sqrt((x - s_x)*(x - s_x) + (y - s_y)*(y - s_y))
    end

    def f_score(pos)
        h_score(pos) + g_score(pos)
    end

    def solve
        while !@open.empty?
            current = @open.first
            (0...@open.length).each do |i|
                if f_score(@open[i]) < f_score(current) || f_score(@open[i]) == f_score(current) && h_score(@open[i]) < h_score(current)
                    current = @open[i]
                end
            end
            @open.delete(current)
            
            
            if current == @end
                return mark_road
            end

            get_neighbours(current).each do |neighbour|
                if @close.include?(neighbour)
                    next
                end
                if !@open.include?(neighbour) || g_score(current) + h_score(current, neighbour) < g_score(neighbour)
                    @close[neighbour] = current
                    if !@open.include?(neighbour)
                        @open.unshift(neighbour)
                    end
                end
            end
        end
    end
    
    def build_path(target)
        path = []
        until target == nil
            path << target
            target = @close[target]
        end
        path.reverse
    end

    def mark_road
        path = build_path(@end)
        path.each do |ele|
            x, y = ele
            @maze[x][y] = "X" if @maze[x][y] == " "
        end
        @maze.each { |line| p line.join("") }
    end
end

if $PROGRAM_NAME == __FILE__
    MazeSolver.new("./maze3.txt").solve
end