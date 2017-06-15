# == Schema Information
#
# Table name: reports
#
#  id            :uuid(16)         not null, primary key
#  message_id    :uuid(16)         not null
#  node          :string           not null
#  delivery_date :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  sqlite_autoindex_reports_1  (id) UNIQUE
#

class Report < ApplicationRecord
  include ActiveUUID::UUID
  belongs_to :message
end
