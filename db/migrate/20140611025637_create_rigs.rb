class CreateRigs < ActiveRecord::Migration
  def change
    create_table :rigs do |t|
      t.string :station
      t.integer :letter
      t.integer :rig_number
      t.string :label
      t.integer :mode
      t.decimal :transmit_frequency, :precision => 22, :scale => 12
      t.decimal :receive_frequency, :precision => 22, :scale => 12

      t.timestamps
    end
  end
end
