class Simulation
  attr_reader :message, :current_node

  def initialize(message, current_node)
    @message = message
    @current_node = current_node
  end

  def as_json
    {
      id: message.id,
      path: path.map { |node| node.as_json2 },
      lastReport: lastReport,
      deliveryTime: deliveryTime,
      speedFactor: 1.0,
    }
  end

  def path
    shortest_path
  end

  private

  def shortest_path
    paths = PathService.new.paths
    paths[message.source][1..-1].reverse.concat(paths[message.destination]).collect { |name| Node.where(name: name).take }
  end

  def destination
    @destination ||= Node.where(name: message.destination).take
  end

  def source
    @source ||= Node.where(name: message.source).take
  end

  def lastReport
    report = Report.where(message_id: message.id).order('delivery_date DESC').first
    if report
      {
        name: report.node,
        time: (report.delivery_date.to_f * 1000).to_i
      }
    else
      {
        name: source.name,
        time: (message.created_at.to_f * 1000).to_i
      }
    end
  end

  def deliveryTime
    remainingPath = path.slice_before { |node| node.name == lastReport[:name] }.to_a[-1]
    remainingDistance = remainingPath.slice(0, remainingPath.size-1)
      .zip(remainingPath.slice(1, remainingPath.size-1))
      .map{ |nodes| NodesDistanceCalculator.call(nodes[0], nodes[1]) }
      .sum

    lastReport[:time] + DistanceToTimeConverter.new(remainingDistance).time * 1000
  end
end
