require 'byebug'
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
        # @open = [] # List that will take neighbors
        @close = [@start] # Path
    end

    def find_coor(symbol) # To find start and end points.
        @maze.each_with_index do |line, i|
            return [i, line.index(symbol)] if line.include?(symbol)
        end
    end

    def get_neighbors(pos)
        neighbors = DELTAS.map do |(dx, dy)|
            [pos[0] + dx, pos[1] + dy]
        end.select do |x, y|
            @maze[x][y] != "*"
        end
    end

    def h_score(pos)
        x, y = pos
        e_x, e_y = @end
        (x - e_x).abs + (y - e_y).abs
    end

    def f_score(pos)
        h_score(pos) + @close.length
    end

    def get_highest(positions)
        hash = {}
        positions.each do |pos|
            hash[pos] = f_score(pos)
        end
        hash = hash.sort_by { |key, value| value }
        hash.each do |key, value|
            return key if @close.include?(key) == false
        end
    end

    def render        
        system('clear')
        @close.each do |ele|
            x, y = ele
            if @maze[x][y] == " "
                @maze[x][y] = "X"
            end
        end
        
        @maze.each { |line| p line.join("") }
    end

    def solve
        # debugger
        until @close.include?(@end)
            @close.unshift(get_highest(get_neighbors(@close.first)))
            render
        end
    end
end

if $PROGRAM_NAME == __FILE__
    MazeSolver.new("./maze1.txt").solve
end
