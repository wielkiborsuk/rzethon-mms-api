class AddSpeedFactorToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :speed_factor, :float
  end
end
