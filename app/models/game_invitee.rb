class GameInvitee < ActiveRecord::Base
  belongs_to :game, inverse_of: :game_invitees
  validates :game, presence: true

  belongs_to :user
  validates :user, presence: true
end
