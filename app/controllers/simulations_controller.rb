class SimulationsController < ApplicationController
  def index
    messages = Message.simulated
    messages = messages.where(sender: @current_user) if @current_user
    messages = messages.map do |message|
      Simulation.new(message, Node.current).as_json
    end

    render json: { messages: messages }
  end

  def paths
    render json: { paths: PathService.new.paths }
  end
end
