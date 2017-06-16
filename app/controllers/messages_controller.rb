class MessagesController < ApplicationController
  def create
    message = Message.new(message_params.merge(source: Redis.current.get('node_name')))

    if message.save
      MessageSenderService.deliver(message.reload)
      render json: { message: message }
    else
      render json: { error: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def message_params
    params.require(:message).permit(:content, :destination, :sender, :receiver)
  end

  def full_message_params
    params.require(:message).permit(:content, :destination, :sender, :receiver, :id, :source)
  end

  def report_params
    params.require(:report).permit(:id, :message_id, :node, :delivery_date)
  end

  def index
    render json: { messages: Message.all }
  end

  def reports
    render json: { reports: Report.all }
  end

  def deliver
    message = Message.new(full_message_params)
    if message.save
      MessageSenderService.deliver(message.reload)

      report = Report.new(message_id: message.id, node: Redis.current.get('node_name'), delivery_date: DateTime.now)
      if report.save
        MessageSenderService.new(message.reload).send_report(report.reload)
      end
    end
  end

  def report
    report = Report.new(report_params)
    if report.save
      message = Message.where(id: report.message_id).take
      MessageSenderService.new(message).send_report(report.reload)
    end
  end
end
