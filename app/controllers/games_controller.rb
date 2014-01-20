class GamesController < ApplicationController

	# GET /games
	def index
		@games = Game.order(created_at: :desc)
		# render games/index.html.erb
	end

	# GET /games/1
	def show
		@game = Game.find(params[:id])
	end

	# GET /games/new
	def new
		@game = Game.new
		# render games/new.html.erb
	end

	# POST /games
	def create
		@game = Game.new(game_params)
		@game.status = GameStatus::WAITING_FOR_PLAYERS
		@game.creator_id = current_user.id
		saved = @game.save
		if saved
			redirect_to games_url, :notice => 'Your game was created. Invite some people to play!'
		else
			render :action => :new
		end
	end

	private
		def game_params
			params.require(:game)
				.permit(:title, :player_count)
		end
end
