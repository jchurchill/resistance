module GamesHelper
	def get_status_display (game)
		case game.status
		when GameStatus::CANCELLED
			"Cancelled"
		when GameStatus::WAITING_FOR_PLAYERS
			"Waiting for players to join"
		when GameStatus::IN_PROGRESS
			"In progress"
		when GameStatus::COMPLETED
			"Completed"
		else
			raise "Unrecognized game status for game #{game.id}"
		end
	end

	def valid_player_counts
		return (5..10).to_a
	end

	def get_view_for_status (game)
		case game.status
		when GameStatus::CANCELLED
			'cancelled'
		when GameStatus::WAITING_FOR_PLAYERS
			'waiting_for_players'
		when GameStatus::IN_PROGRESS
			'in_progress'
		when GameStatus::COMPLETED
			'complete'
		else
			raise "Unrecognized game status for game #{game.id}"
		end
	end
end
