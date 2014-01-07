class CreateNominees < ActiveRecord::Migration
  def change
    create_table :nominees do |t|
      t.belongs_to :nomination, 	:index => true, :null => false
      t.belongs_to :player, 			:index => true, :null => false

      t.timestamps
    end
  end
end
