class Nominee < ActiveRecord::Base
  belongs_to :nomination, class_name: :round_nomination
  belongs_to :player
end
