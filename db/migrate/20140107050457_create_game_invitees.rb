class CreateGameInvitees < ActiveRecord::Migration
  def change
    create_table :game_invitees do |t|
      t.references 	:game, 			:index => true, :null => false
      t.references 	:user, 			:index => true, :null => false
      t.boolean 		:is_joined, 								:null => false, :default => false

      t.timestamps
    end
  end
end
