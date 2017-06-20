class MessagesController < ApplicationController
  def create
    message = Message.new(message_params.merge(source: Redis.current.get('node_name')))

    if message.save
      broadcast_simulations(message.sender)
      MessageSenderService.call(message.reload)
      render json: { message: message }
    else
      render json: { error: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def index
    render json: { messages: Message.all }
  end

  def sent
    messages = Message.simulated
    messages = messages.where(sender: @current_user) if @current_user
    render json: { messages: messages }
  end

  def received
    messages = Message.delivered
    messages = messages.where(receiver: @current_user) if @current_user
    render json: { messages: messages }
  end

  def reports
    render json: { reports: Report.all }
  end

  def deliver
    message = Message.new(full_message_params)
    if message.save
      MessageSenderService.call(message.reload)
      ActionCable.server.broadcast "deliveries_#{message.receiver}", message: message

      report = Report.new(message_id: message.id, node: Redis.current.get('node_name'), delivery_date: DateTime.now, source: message.source, speed_factor: message.speed_factor)
      if report.save
        ReportSenderService.call(report.reload)
      end
    end
  end

  def report
    report = Report.new(report_params)
    if report.save
      ReportSenderService.call(report.reload)
      broadcast_delivery_report(report.reload)
    end
  end

  private

  def broadcast_delivery_report(report)
      message = Message.where(id: report.message_id).take
      if message and message.destination == report.node
        ActionCable.server.broadcast "deliveries_#{message.sender}", report: message
        broadcast_simulations(message.sender)
      end
  end

  def broadcast_simulations(user)
    messages = Message.simulated
    messages = messages.where(sender: @current_user) if @current_user
    messages = messages.map do |message|
      Simulation.new(message, Node.current).as_json
    end

    ActionCable.server.broadcast "simulations_#{user}", messages: messages
  end

  def message_params
    params.require(:message).permit(:content, :destination, :sender, :receiver, :speed_factor).tap do |message|
      message[:speed_factor] = params[:message][:speedFactor]
    end
  end

  def full_message_params
    params.require(:message).permit(:content, :destination, :sender, :receiver, :id, :source, :speed_factor, :created_at)
  end

  def report_params
    params.require(:report).permit(:id, :message_id, :node, :delivery_date, :source, :speed_factor)
  end
end
