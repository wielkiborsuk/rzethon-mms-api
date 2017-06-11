class AddMessageSenderReceiverToMessage < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :sender, :string
    add_column :messages, :receiver, :string
  end
end
