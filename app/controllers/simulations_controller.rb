class SimulationsController < ApplicationController
  def index
    messages = Message.simulated.map do |message|
      Simulation.new(message, Node.current).as_json
    end

    render json: { messages: messages }
  end

  def paths
    render json: { paths: PathService.new.paths }
  end
end
