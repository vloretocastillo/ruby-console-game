require "colorize"

#****** ***** ***** ***** ***** OFTEN CALLED ***** ***** ***** ***** *****

def message( message )
    print "#{ message }"
    gets
    print "\n"
end

def render_board( arg_matrix )
    print "\n"
    for i in 0..arg_matrix.length-1
        if i < 10
            print "0#{ i }   ||   ".colorize(:color => :yellow)
        else
            print "#{ i }   ||   ".colorize(:color => :yellow)
        end
        for j in 0..arg_matrix[i].length-1
            print "  #{ arg_matrix[i][j] }  "
        end
        print "   ||\n\n".colorize(:color => :yellow)
    end
    print "\n"
end

def change_value( board, row, col, value )
    board[ row ][ col ] = value.to_s
end

def render_all(hack_life, torpedos_available, turn_counter, board, torpedos_deployed, mines_deployed)
    system("clear")
    render_board( board )
    print "Hackzilla's life: #{ hack_life } \n\n".colorize(:color => :white, :background => :red)
    print "Torpedoes available: #{ torpedos_available } \n".colorize(:color => :white, :background => :blue)
    print "Torpedoes exploted : #{ torpedos_deployed } \n\n".colorize(:color => :white, :background => :blue)
    print "Mines deployed: #{ mines_deployed } \n\n".colorize(:color => :white, :background => :blue)
    print "Turn: #{turn_counter} \n\n".colorize(:color => :black, :background => :green)
end

def find_hackzilla( board )
    location = Array.new
    for i in 0..board.length-1
        for j in 0..board[i].length-1
            if board[i][j] == "|H|".colorize(:color => :white, :background => :green)
                location.push(i)
                location.push(j)
                return location
            end
        end
    end
end

def find_torpedo( board )
    location = Array.new
    for i in 0..board.length-1
        for j in 0..board[i].length-1
            if board[i][j] == "!^!".colorize(:color => :white, :background => :blue)
                location.push( [i,j] )
            end
        end
    end
    return location
end

def hackzilla_forward( row_max, board, i, j, mines_deployed, hack_life, torpedos_deployed, shore )
    if i != row_max
        board[ i ][ j ] = "..."
        if board[ i + 1 ][ j ] == "{$}".colorize(:color => :red)
            mines_deployed[0] += 1
            hack_life[0] -= 35
        end
        if board[ i + 1 ][ j ] == "!^!".colorize(:color => :white, :background => :blue)
            torpedos_deployed[0] += 1
            hack_life[0] -= 50
        end
        change_value( board, i + 1, j, "|H|".colorize(:color => :white, :background => :green) )
    else
        shore[0] = true
    end
end

def hackzilla_right( col_max, board, i, j, mines_deployed, hack_life, torpedos_deployed, shore )
    if j != col_max
        board[ i ][ j ] = "..."
        if board[ i ][ j + 1 ] == "{$}".colorize(:color => :red)
            mines_deployed[0] += 1
            hack_life[0] -= 35
        end
        if board[ i ][ j + 1 ] == "!^!".colorize(:color => :white, :background => :blue)
            torpedos_deployed[0] += 1
            hack_life[0] -= 50
        end
        change_value( board, i, j + 1, "|H|".colorize(:color => :white, :background => :green) )
    end
end

def hackzilla_left( board, i, j, mines_deployed, hack_life, torpedos_deployed, shore )
    if j != 0
        board[ i ][ j ] = "..."
        if board[ i ][ j - 1 ] == "{$}".colorize(:color => :red)
            mines_deployed[0] += 1
            hack_life[0] -= 35
        end
        if board[ i ][ j - 1 ] == "!^!".colorize(:color => :white, :background => :blue)
            torpedos_deployed[0] += 1
            hack_life[0] -= 50
        end
        change_value( board, i, j - 1, "|H|".colorize(:color => :white, :background => :green) )
    end
end

def pick_move( dice, i, j, board, hack_life, shore, mines_deployed, torpedos_deployed )
    row_max = (board.length) -1
    col_max = (board[0].length) -1
    case dice
    when 1
        hackzilla_forward( row_max, board, i, j, mines_deployed, hack_life, torpedos_deployed, shore )
    when 2
        hackzilla_right( col_max, board, i, j, mines_deployed, hack_life, torpedos_deployed, shore )
    when 3
        hackzilla_left( board, i, j, mines_deployed, hack_life, torpedos_deployed, shore )
    end
end

def hackzilla_choice( dice, hack_life, board, shore, mines_deployed, torpedos_deployed )
    if dice == 0
        hack_life[0] += 10
    else
        hackzilla_params = find_hackzilla( board )
        pick_move( dice, hackzilla_params[0], hackzilla_params[1], board, hack_life, shore, mines_deployed, torpedos_deployed )
    end
end

def torpedo_movement_manager( board, hack_life , torpedos_deployed )
    torpedo_params = find_torpedo( board )
    torpedos_number = torpedo_params.length
    for i in 0..torpedos_number-1
        if torpedo_params[i][0]  != 0
            if board[  torpedo_params[i][0] -1 ][ torpedo_params[i][1] ] != "|H|".colorize(:color => :white, :background => :green)
                board[  torpedo_params[i][0]  ][ torpedo_params[i][1] ] = "..."
                change_value( board, torpedo_params[i][0] - 1,  torpedo_params[i][1] , "!^!".colorize(:color => :white, :background => :blue) )
            else
                board[  torpedo_params[i][0]  ][ torpedo_params[i][1] ] = "..."
                change_value( board, torpedo_params[i][0] - 1,  torpedo_params[i][1] , "|H|".colorize(:color => :white, :background => :green) )
                hack_life[0] -= 50
                torpedos_deployed[0] += 1
            end
        end
    end
end

def turn_manager( hack_life, board, shore, mines_deployed, turn_counter, torpedos_deployed, torpedos_available)
    render_all( hack_life, torpedos_available, turn_counter, board, torpedos_deployed, mines_deployed )
    message("HACKZILLA'S MOVE")
    dice = rand(4)
    hackzilla_choice( dice, hack_life, board, shore, mines_deployed, torpedos_deployed )
    render_all( hack_life, torpedos_available, turn_counter, board, torpedos_deployed, mines_deployed)
    message("YOUR MOVE")
    if torpedos_available[0] < 3
        torpedo_movement_manager( board, hack_life , torpedos_deployed )
    end
    if torpedos_available[0] > 0
        answer = player_wants_torpedo( torpedos_available )
        if answer == "y"
            add_torpedo( board )
            torpedos_available[0] -= 1
        end
    end
    render_all( hack_life, torpedos_available, turn_counter, board, torpedos_deployed, mines_deployed )
end

# ******* ***** ***** ***** *****  CALLED ONCE ***** ***** ***** ***** *****

def empty_board()
    board = []
    row = 10
    col = 15
    for i in 0..row -1
        board[i] = []
        for j in 0..col -1
            board[i][j] = "..."
        end
    end
    return board
end

def add_mines( board )
    mine_num = 0
    while mine_num <= 0 || mine_num > 30
        print "Up there's the board you'll be playing in\n\nChoose how many mines to place on the board, as long as the number is within the 1-30 range : "
        mine_num = gets.chomp.to_i
    end
    message("\nFirst, you must place #{ mine_num } mines all over the board")
    message("All the \"...\" represent the spots where you can place you mine")
    message("First I'll ask you for the  vertical values; then I'll ask you for the horizontal ones")
    row_max = (board.length)-1
    row_min = 1
    col_max = (board[0].length)-1
    col_min = 0
    while 0 < mine_num
        row = row_max + 5
        col = col_max + 5
        print "NUMBER OF MINES AVAILABLE: #{ mine_num }\n\n".colorize(:color => :blue)
        while row > (row_max-1) || row < row_min do
            print "VERTICAL VALUE --any number between #{ row_min } and #{ row_max - 1 } :   ".colorize(:color => :yellow)
            row = gets.chomp.to_i
            print "\n"
        end
        while col > col_max || col < col_min do
            print "HORIZONTAL VALUE -- any number between #{ col_min } and #{ col_max } : ".colorize(:color => :red)
            col = gets.chomp.to_i
            print "\n"
        end
        if board[row][col] == "..."
            change_value( board, row, col, "{$}".colorize(:color => :red) )
            mine_num -= 1
        end
        system("clear")
        render_board( board )
    end
end

def add_hackzilla( board )
    done = false
    while !done do
        j = rand( 10 )
        change_value( board, 0 , j , "|H|".colorize(:color => :white, :background => :green)   )
        done = true
    end
end

def initializes_board()
    message(  "\n\n\n\n       WELCOME YOU FOOL\n\n\n\n      (press enter to begin)" )
    system("clear")
    board = empty_board()
    render_board( board )
    add_mines(  board )
    add_hackzilla( board )
    message("Your board is ready. Press any key to begin playing....")
    return board
end

# ******* ***** ***** ***** *****  LIMITED NUMBER OF CALLS ***** ***** ***** ***** *****

def add_torpedo( board )
    row = (board.length) -1
    col_max = (board[0].length) -1
    col_min = 0
    col = col_max + 5
    while col > col_max || col < col_min do
        print "DEFINE THE COLUMN - Write any number between #{ col_min } and #{ col_max }, inclusive: ".colorize(:color => :red)
        col = gets.chomp.to_i
        print "\n"
    end
    if board[row][col] == "..."
        change_value( board, row, col, "!^!".colorize(:color => :white, :background => :blue) )
    end
end

def player_wants_torpedo( torpedos_available )
    answer = ""
    while answer != "y" &&  answer != "n" do
        print "You have #{ torpedos_available } torpedoes in storage. Do you wish to use one? y / n : "
        answer = gets.chomp.to_s
    end
    return answer
end

# ******* ***** ***** ***** *****  BASE CALL ***** ***** ***** ***** *****

def game_manager()
    hack_life = [100]
    torpedos_available = [3]
    torpedos_deployed = [0]
    mines_deployed = [0]
    shore = [false]
    board = []
    turn_counter = [0]
    while hack_life[0] > 0 && shore[0] == false
        if turn_counter[0] == 0
            board = initializes_board()
            turn_counter[0] += 1
        else
            turn_manager( hack_life, board, shore, turn_counter, mines_deployed, torpedos_deployed, torpedos_available)
            turn_counter[0] += 1
        end
    end
    if hack_life[0] <= 0
        system("clear")
        message("YOU WON!")
        render_all( hack_life, torpedos_available, turn_counter, board, torpedos_deployed, mines_deployed )
        message("WINNER: YOU, FOOL!")
    else
        system("clear")
        message("you lost!")
        render_all( hack_life, torpedos_available, turn_counter, board, torpedos_deployed, mines_deployed )
        message("WINNER: HACKZILLA")
    end

end

game_manager()
