class DeliveryChannel < ApplicationCable::Channel
  def subscribed
    stream_from "deliveries_#{params['user']}"
  end
end
