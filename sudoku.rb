require 'byebug'

class Sudoku
    def initialize(board_string)
        @backtrack_array = board_string.to_s.split("").map { |digit| digit.to_i }
        @backtrack_board = @backtrack_array.each_slice(9).to_a
        @board_horizontal = Marshal.load(Marshal.dump(@backtrack_board))
        @horizontal_arr = Marshal.load(Marshal.dump(@backtrack_array))
        @backtrack_squares = []
        square_arr = Marshal.load(Marshal.dump(@board_horizontal))
        3.times do
            3.times do
                temp_board = []
                for i in (0..2)
                    selected = square_arr[i].take(3)
                    selected.each {|x| temp_board << x}
                    square_arr[i] = square_arr[i].drop(3)
                end
                @backtrack_squares << temp_board
            end
            square_arr = square_arr.drop(3)
        end
        @board_squares = Marshal.load(Marshal.dump(@backtrack_squares))
        @counter = @horizontal_arr.count(0)
        @squares_x = [[0, 0, 0, 1, 1, 1, 2, 2, 2],
        [0, 0, 0, 1, 1, 1, 2, 2, 2],
        [0, 0, 0, 1, 1, 1, 2, 2, 2],
        [3, 3, 3, 4, 4, 4, 5, 5, 5],
        [3, 3, 3, 4, 4, 4, 5, 5, 5],
        [3, 3, 3, 4, 4, 4, 5, 5, 5],
        [6, 6, 6, 7, 7, 7, 8, 8, 8],
        [6, 6, 6, 7, 7, 7, 8, 8, 8],
        [6, 6, 6, 7, 7, 7, 8, 8, 8]]
        @squares_y = [[0, 1, 2, 0, 1, 2, 0, 1, 2],
        [3, 4, 5, 3, 4, 5, 3, 4, 5],
        [6, 7, 8, 6, 7, 8, 6, 7, 8],
        [0, 1, 2, 0, 1, 2, 0, 1, 2],
        [3, 4, 5, 3, 4, 5, 3, 4, 5],
        [6, 7, 8, 6, 7, 8, 6, 7, 8],
        [0, 1, 2, 0, 1, 2, 0, 1, 2],
        [3, 4, 5, 3, 4, 5, 3, 4, 5],
        [6, 7, 8, 6, 7, 8, 6, 7, 8]]
    end
    
    def locate(value)
        x = value / 9
        y = value % 9
        if x < 3
            return @board_squares[0] if y < 3
            return @board_squares[1] if y < 6
            return @board_squares[2] if y < 9
            elsif x < 6
            return @board_squares[3] if y < 3
            return @board_squares[4] if y < 6
            return @board_squares[5] if y < 9
            elsif x < 9
            return @board_squares[6] if y < 3
            return @board_squares[7] if y < 6
            return @board_squares[8] if y < 9
        end
    end
    
    def multiple?(board)
        count = 0
        board.each do |row|
            if row.uniq.length == row.length && row.include?(0) == false
                count += 1
                else return false
            end
        end
        return true if count == 9
    end
    
    def run_through
        10.times do
            @counter = @horizontal_arr.count(0)
            zeros = []
            @horizontal_arr.each_with_index {|value, place| zeros << place if value == 0}
            zeros.each do |x|
                possible = [1, 2, 3, 4, 5, 6, 7, 8, 9]
                possible -= @board_horizontal[x/9]
                possible -= @board_horizontal.transpose[x%9]
                position = locate(x)
                possible -= position
                if possible.length == 1
                    @board_horizontal[x/9][x%9] = possible[0]
                    @board_squares[@squares_x[x/9][x%9]][@squares_y[x/9][x%9]] = possible[0]
                    @counter -= 1
                    zeros -= [x]
                end
            end
            @horizontal_arr = @board_horizontal.flatten
        end
    end
    
    def solve!
        boards_check = false
        until boards_check == true
            @board_horizontal = Marshal.load(Marshal.dump(@backtrack_board))
            @horizontal_arr = Marshal.load(Marshal.dump(@backtrack_array))
            @board_squares = Marshal.load(Marshal.dump(@backtrack_squares))
            run_through
            @guess_counter = @horizontal_arr.count(0)
            if @counter == 0
                return @board_horizontal
            end
            @guess_counter = @horizontal_arr.count(0)
            zeros = []
            @horizontal_arr.each_with_index {|value, place| zeros << place if value == 0}
            zeros.each do |x|
                possible = [1, 2, 3, 4, 5, 6, 7, 8, 9]
                possible -= @board_horizontal[x/9]
                possible -= @board_horizontal.transpose[x%9]
                position = locate(x)
                possible -= position
                if possible.empty? == false
                    guess = possible.sample
                    @board_horizontal[x/9][x%9] = guess
                    @board_squares[@squares_x[x/9][x%9]][@squares_y[x/9][x%9]] = guess
                    possible -= [possible.sample]
                    zeros -= [x]
                end
                run_through
                if multiple?(@board_horizontal) == true && multiple?(@board_horizontal.transpose) == true && multiple?(@board_squares) == true
                    boards_check = true
                end
            end
        end
    end
    
    # Returns a string representing the current state of the board
    # Don't spend too much time on this method; flag someone from staff
    # if you are.
    def board
        @board_horizontal.flatten.join("")
    end
end

# The file has newlines at the end of each line, so we call
# String#chomp to remove them.
#board_string = File.readlines('sample.unsolved.txt').first.chomp

game = Sudoku.new('096040001100060004504810390007950043030080000405023018010630059059070830003590007')

# Remember: this will just fill out what it can and not "guess"
game.solve!

puts game.board