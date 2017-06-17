class MessageSenderService
  attr_reader :message, :current_node

  def initialize(message)
    @message = message
    @current_node = Node.current
  end

  def self.call(*args)
    new(*args).send_message
  end

  def send_message
    if destination_node then
      Rails.logger.debug "Message uuid: #{message.id} will be sent in #{time_remaning_to_next_node(destination_node)} seconds to #{destination_node.host}"
      SendMessageWorker.perform_in(time_remaning_to_next_node(destination_node).seconds, destination_node.host, message.id)
    end
  end

  private

  def time_remaning_to_next_node(target_node)
    distance = NodesDistanceCalculator.call(current_node, target_node)
    DistanceToTimeConverter.new(distance).time.presence / message.speed_factor || 1
  end

  def destination_node
    @destination_node ||= begin
      Node.where(name: PathService.new.paths[message.destination][1]).take
    end
  end
end
