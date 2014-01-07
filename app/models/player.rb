class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game, inverse_of: :players
end
