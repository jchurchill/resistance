class Nominee < ActiveRecord::Base
  belongs_to :nomination, class_name: 'RoundNomination'
  belongs_to :player
end
