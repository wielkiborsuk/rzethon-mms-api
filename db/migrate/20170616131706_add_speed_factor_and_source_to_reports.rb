class AddSpeedFactorAndSourceToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :speed_factor, :float
    add_column :reports, :source, :string
  end
end
