class AddLockVersionToQso < ActiveRecord::Migration
  def change
      add_column :qsos, :lock_version, :integer, :default => 0
  end
end
