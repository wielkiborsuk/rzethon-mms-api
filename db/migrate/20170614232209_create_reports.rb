class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports, id: :uuid do |t|
      t.uuid :message_id, foreign_key: true, null: false
      t.string :node, null: false
      t.datetime :delivery_date, null: false

      t.timestamps
    end
  end
end
