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

  def index
    render json: { messages: Message.all }
  end

  def deliver
    message = Message.new(message_params)
    if message.save
      MessageSenderService.deliver(message.reload)
      MessageSenderService.report(message.reload)
    end
  end

  def report
  end
end
