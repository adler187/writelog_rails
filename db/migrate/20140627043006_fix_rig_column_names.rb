class FixRigColumnNames < ActiveRecord::Migration
    def up
        rename_column :rigs, :mode, :mode_key
        rename_column :rigs, :label, :network_display_name
        rename_column :rigs, :letter, :network_letter
        rename_column :rigs, :station, :username
    end

    def down
        rename_column :rigs, :mode_key, :mode
        rename_column :rigs, :network_display_name, :label
        rename_column :rigs, :network_letter, :letter
        rename_column :rigs, :username, :station
    end
end
