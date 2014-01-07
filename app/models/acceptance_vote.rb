class AcceptanceVote < ActiveRecord::Base
  belongs_to :nomination, class_name: :round_nomination, inverse_of: :acceptance_votes
  belongs_to :player
end
