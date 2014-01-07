class RoundNomination < ActiveRecord::Base
  belongs_to :round, class_name: :game_round, inverse_of: :round_nominations
  belongs_to :nominating_player, class_name: :player
  has_many :nominated_players, class_name: :player, through: :nominees
  has_many :acceptance_votes, inverse_of: :nomination
end
