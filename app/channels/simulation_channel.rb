class SimulationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "simulations_#{params['user']}"
  end
end
