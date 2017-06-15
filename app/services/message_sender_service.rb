class MessageSenderService
  attr_reader :message, :current_node

  def initialize(message)
    @message = message
    @current_node = Node.current
  end

  def self.deliver(*args)
    new(*args).send_message
  end

  def send_message
    if destination_node then
      Rails.logger.debug "Message uuid: #{message.id} will be sent in #{time_remaning_to_next_node(destination_node)} seconds to #{destination_node.host}"
      SendMessageWorker.perform_in(time_remaning_to_next_node(destination_node).seconds, destination_node.host, message.id)
    end
  end

  def send_report(report)
    if report_node then
      Rails.logger.debug "Report for message uuid: #{message.id} will be sent in #{time_remaning_to_next_node(report_node)} seconds to #{report_node.host}"
      SendReportWorker.perform_in(time_remaning_to_next_node(report_node).seconds, report_node.host, report.id)
    end
  end

  private

  def time_remaning_to_next_node(target_node)
    distance = NodesDistanceCalculator.call(current_node, target_node)
    (DistanceToTimeConverter.new(distance).time.presence || 1)/ 10
  end

  def destination_node
    @destination_node ||= begin
      source = Node.where(name: message.source)
      simulation = Simulation.new(message, source)
      #binding.pry
      index = simulation.path.index(current_node)
      simulation.path[index+1]
    end
  end

  def report_node
    @report_node ||= begin
      source = Node.where(name: message.source)
      simulation = Simulation.new(message, source)
      #binding.pry
      index = simulation.path.reverse.index(current_node)
      simulation.path.reverse[index+1]
    end
  end
end
