class SendMessageWorker
  include Sidekiq::Worker
  sidekiq_options dead: false

  def perform(host, message_uuid)
    message = Message.where(id: message_uuid).take
    NodeService.new(host).send_message(message.as_json)
  end
end

