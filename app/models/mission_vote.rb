class MissionVote < ActiveRecord::Base
  belongs_to :round, class_name: 'GameRound', inverse_of: :mission_votes
  belongs_to :player
end
