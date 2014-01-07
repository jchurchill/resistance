class GameInvitee < ActiveRecord::Base
  belongs_to :game, inverse_of: :game_invitees
  belongs_to :user
end
