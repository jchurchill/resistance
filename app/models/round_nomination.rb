class RoundNomination < ActiveRecord::Base
  belongs_to :round, class_name: 'GameRound', inverse_of: :round_nominations
  belongs_to :nominating_player, class_name: 'Player'
  has_many :nominated_players, class_name: 'Player', through: :nominees
  has_many :acceptance_votes, inverse_of: :nomination
end
