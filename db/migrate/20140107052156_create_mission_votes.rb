class CreateMissionVotes < ActiveRecord::Migration
  def change
    create_table :mission_votes do |t|
      t.references 	:round, 	:index => true, :null => false
      t.references 	:player, 	:index => true, :null => false
      t.boolean 		:is_pass, 								:null => false

      t.timestamps
    end
  end
end
