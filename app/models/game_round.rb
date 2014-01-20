class GameRound < ActiveRecord::Base
  belongs_to :game, inverse_of: :game_rounds
  validates :game, presence: true

  has_many :round_nominations, inverse_of: :round
  has_many :mission_votes, inverse_of: :round
end
