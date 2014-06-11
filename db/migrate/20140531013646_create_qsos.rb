class CreateQsos < ActiveRecord::Migration
  def change
    create_table :qsos do |t|
      t.integer :time_upper
      t.integer :time_lower
      t.decimal :transmit_frequency, :precision => 10, :scale => 0
      t.decimal :receive_frequency, :precision => 10, :scale => 0
      t.integer :band
      t.string  :station
      t.integer :mode
      t.integer :dupe
      t.integer :serial
      t.integer :version
      t.string  :id_key
      t.string  :updated_by
      t.string  :operating_class
      t.string  :section
      t.string  :c_field
      t.string  :country_prefix
      t.timestamps
    end
  end
end
