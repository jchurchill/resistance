class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.references 	:user, 		:index => true, :null => false
      t.references 	:game, 		:index => true, :null => false
      t.integer 		:role_id, 								:null => false

      t.timestamps
    end
  end
end
