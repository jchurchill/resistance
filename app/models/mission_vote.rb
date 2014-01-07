class MissionVote < ActiveRecord::Base
  belongs_to :round, class_name: :game_round, inverse_of: :mission_votes
  belongs_to :player
end
