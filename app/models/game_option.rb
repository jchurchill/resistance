class GameOption < ActiveRecord::Base
  belongs_to :game, inverse_of: :game_options
  validates :game, presence: true
end
