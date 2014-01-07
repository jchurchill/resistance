class CreateRoundNominations < ActiveRecord::Migration
  def change
    create_table :round_nominations do |t|
      t.references  :round,             :index => true, :null => false
      t.integer     :phase,                             :null => false
      t.references  :nominating_player, :index => true, :null => false
      t.boolean     :is_accepted,                       :null => false, :default => false

      t.timestamps
    end
  end
end
