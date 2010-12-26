class Chess
  class Board < Chess
  
    def initialize
	  rows = {}
	  row = [0,1,0,1,0,1,0,1]
	  [1,3,5,7].each{|i| rows[i] = row; rows[i + 1] = row.reverse}
	  @board = rows
	  @light_dead = []
	  @dark_dead = []
	  @player1 = 'light'
	  @player2 = 'dark'
	  @turn = @player1
	  @a_king_is_dead = false
	end

	def a_king_is_dead?
	  @a_king_is_dead
	end

	def current_player
	  @turn
	end

	def dead_dark
	  @dark_dead
	end

	def dead_light
	  @light_dead
	end

	def kill(piece)
	  if piece.team == "light"
		@light_dead << piece
	  else
		@dark_dead << piece
	  end
	  @a_king_is_dead = true if piece.is_a?(Chess::Piece::King)
	end

	def dead_opponents(player)
	  if player == 'light'
		dead_dark
	  else
		dead_light
	  end
	end


	def change_player
	  @turn  = @turn == 'light' ? 'dark' : 'light'
	end

	def layout
	  @board
	end

	def row
	  @board
	end

	def square(coords)
	  r = coords[0].to_i
	  s = (coords[1].to_i) -1
	  row[r][s]
	end

	def place_piece(piece, coords)
	  r,s = coords
	  @board[r][s] = piece
	end

	def pieces
	  nobles = [Piece::Rooke.new,Piece::Knight.new,Piece::Bishop.new,Piece::Queen.new,Piece::King.new,Piece::Bishop.new,Piece::Knight.new, Piece::Rooke.new]
	  dark_nobles = [Piece::Rooke.new('dark'),Piece::Knight.new('dark'),Piece::Bishop.new('dark'),Piece::Queen.new('dark'),Piece::King.new('dark'),Piece::Bishop.new('dark'),Piece::Knight.new('dark'), Piece::Rooke.new('dark')]
	  peasants = [Piece::Pawn.new,Piece::Pawn.new,Piece::Pawn.new,Piece::Pawn.new,Piece::Pawn.new,Piece::Pawn.new,Piece::Pawn.new,Piece::Pawn.new]
	  dark_peasants = [Piece::Pawn.new('dark'),Piece::Pawn.new('dark'),Piece::Pawn.new('dark'),Piece::Pawn.new('dark'),Piece::Pawn.new('dark'),Piece::Pawn.new('dark'),Piece::Pawn.new('dark'),Piece::Pawn.new('dark')]
    	  row[1] = nobles
    	  row[2] = peasants
	  row[8] = dark_nobles.reverse
	  row[7] = dark_peasants
	end

	def is_white?(coords)
	  r, s = coords
	  s -= 1
	  if r.even?
		s.even? ? false : true
	  else
		s.even? ? true : false
	  end
	end

	def make_default_color!(coords)
       r,s = coords
	  s -= 1
	  color = is_white?(coords) ? 0 : 1
	  @board[r][s] = color
	end
  end

  class Piece
	def move!(board, before, after)
#	  return false if team != board.current_player
	  return false unless board.square(before).is_a?(Piece)
#	  return false if board.square(after).is_a?(Piece)
	  piece = board.square(before)
	  board.place_piece(piece, after)
	  board.make_default_color!(before)
	end

     class Rooke < Piece
       def initialize(color='light'); @team=color;end
	  def team; @team;end 
	  def cant_move_there?(before, after)
		r,s = before
		ar, as = after
		return true if r != ar && s != as
		return true if r == ar && s == as
		false
	  end
	end
     class Knight < Piece
       def initialize(color='light'); @team=color;end 
	  def team; @team;end 
	  def cant_move_there?(before, after)
		r,s = before
		ar, as = after
		if ar == r - 1 || ar == r + 1
		  return true if as == s - 2 || as == s + 2
		end
		if as == s - 1 || as == s + 1
		  return true if ar == r - 2 || ar == r + 2
		end
		false
	  end
	end
     class Bishop < Piece
       def initialize(color='light'); @team=color;end 
	  def team; @team;end 
	  def cant_move_there?(before, after)
		r,s = before
		ar, as = after
		return true unless (r - ar).abs == (s - as)
		false
	  end
	end
     class Queen < Piece
       def initialize(color='light'); @team=color;end 
	  def team; @team;end 
	  def cant_move_there?(before, after)
		r,s = before
		ar, as = after
		if (r - ar).abs != (s - as)
		  return true if r != ar && s != as
		  return true if r == ar && s == as
		  false
		end
		false
	  end
	end
     class King < Piece
       def initialize(color='light'); @team=color;end 
	  def team; @team;end 
	  def cant_move_there?(before, after)
		r,s = before
		ar, as = after
		return false if (r+s) == (ar+as+1) || (r+s) == (ar+as-1)
		true
	  end
	end

     class Pawn < Piece
       def initialize(color='light'); @team=color;end 
	  def team; @team;end 
	  def cant_move_there?(before, after)
		r,s = before
		ar, as = after
		return true if s != as
		if team == 'light'
		  return true if r != ar -1
		  false
		else
		  return true if r != ar + 1
		  false
		end
	  end
	end
  end
end

class String
  def to_coords
	strip.split(',').collect{|k| k.to_i}
  end
end

board = Chess::Board.new
board.pieces
until board.a_king_is_dead? do
  player = board.current_player
  p "#{player} it's your turn, which peice would you like to move?"
  before = STDIN.gets.to_coords
 
  puts before.class
  case 
  when before == [0]
	p board.row
	redo
  when before.min < 1 
    p "The values must be between 1 and 8"
  redo
  when before.max > 8
	p "The values must be between 1 and 8"
	redo
  end

  piece = board.square(before)
  case 
  when !piece.is_a?(Chess::Piece)
	p "There is not a piece in that square"
	redo
  when piece.team != player
	p "That is not your piece"
	redo
  end
  p "Where would you like to move your #{piece.class}?"
  after = STDIN.gets.to_coords
  case
  when piece.cant_move_there?(before, after) == true
	p "That isn't a move for #{piece.class}"
	redo
  end
  landing = board.square(after)
  if landing.is_a?(Chess::Piece)
	if landing.team == player
	  p "You can't kill your teammate"
	  redo
	else
	  p "You killed your opponents #{landing.class}"
	  board.kill(landing)
	  p "You've killed #{board.dead_opponents(player)}."
	end
  end
	
  board.square(before).move!(board, before, after)
  board.change_player
  p board.layout
end
p "You win!"



