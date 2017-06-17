# == Schema Information
#
# Table name: messages
#
#  id           :uuid(16)         not null, primary key
#  content      :string           not null
#  source       :string           not null
#  destination  :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sender       :string
#  receiver     :string
#  speed_factor :float
#
# Indexes
#
#  sqlite_autoindex_messages_1  (id) UNIQUE
#

class Message < ApplicationRecord
  include ActiveUUID::UUID
  validates :content, :source, :destination, :speed_factor, presence: true
  has_many :reports

  scope :simulated, -> { where(source: Node.current.name) }
end
