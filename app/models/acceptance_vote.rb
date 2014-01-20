class AcceptanceVote < ActiveRecord::Base
  belongs_to :nomination, class_name: 'RoundNomination', inverse_of: :acceptance_votes
	validates :nomination, presence: true

  belongs_to :player
  validates :player, presence: true
end
