class CreateAcceptanceVotes < ActiveRecord::Migration
  def change
    create_table :acceptance_votes do |t|
      t.references :nomination, 	:index => true, :null => false
      t.references :player, 			:index => true, :null => false
      t.boolean :is_accept, 											:null => true

      t.timestamps
    end
  end
end
