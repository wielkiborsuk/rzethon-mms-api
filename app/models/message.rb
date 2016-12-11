# == Schema Information
#
# Table name: messages
#
#  id          :integer          not null, primary key
#  content     :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  uuid        :uuid             not null
#  source      :string           not null
#  destination :string           not null
#
# Indexes
#
#  messages_uuid_key  (uuid) UNIQUE
#

class Message < ApplicationRecord
  validates :content, :source, :destination, presence: true
  scope :current, -> { all }
end
