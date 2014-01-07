class CreateGameRounds < ActiveRecord::Migration
  def change
    create_table :game_rounds do |t|
      t.references  :game,                :index => true, :null => false
      t.integer     :round_number,                        :null => false
      t.boolean     :is_mission_success,                  :null => true
      t.boolean     :is_complete,                         :null => false, :default => false
      t.integer     :nomination_count,                    :null => false
      t.integer     :count_required_for_fail,             :null => false

      t.timestamps
    end
  end
end
