class Game < ActiveRecord::Base
	has_many :game_invitees, inverse_of: :game
	has_many :game_options, inverse_of: :game
	has_many :players, inverse_of: :game
	has_many :game_rounds, inverse_of: :game
	belongs_to :creator, class_name: 'User'

	validates :title, presence: true
	validates :status, inclusion: { in: GameStatus.all.map { |s| s.value } }
	validates :player_count, presence: true
	validates :creator_id, presence: true
end
