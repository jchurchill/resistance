class CreateGameOptions < ActiveRecord::Migration
  def change
    create_table :game_options do |t|
      t.references 	:game, 								:index => true, :null => false
      t.integer 		:enabled_option_type,									:null => false

      t.timestamps
    end
  end
end
