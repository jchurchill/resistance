class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer 	:status, 				:null => false
      t.string 		:title,					:null => false
      t.integer 	:player_count,	:null => false

      t.timestamps
    end
  end
end
