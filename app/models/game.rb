class Game < ActiveRecord::Base
	has_many :game_invitees, inverse_of: :game
	has_many :game_options, inverse_of: :game
	has_many :players, inverse_of: :game
	has_many :game_rounds, inverse_of: :game
end
