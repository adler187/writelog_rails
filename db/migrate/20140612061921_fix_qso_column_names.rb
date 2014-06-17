class FixQsoColumnNames < ActiveRecord::Migration
    def up
        rename_column :qsos, :mode, :mode_key
        rename_column :qsos, :band, :band_key
        rename_column :qsos, :dupe, :dupe_key
    end

    def down
        rename_column :qsos, :mode_key, :mode
        rename_column :qsos, :band_key, :band
        rename_column :qsos, :dupe_key, :dupe
    end
end
