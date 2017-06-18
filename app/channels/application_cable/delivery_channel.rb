class DeliveryChannel < ApplicationCable::Channel
  def subscribed
    #stream_from "deliveries_#{connection.current_user}"
    stream_from "deliveries"
  end
end
