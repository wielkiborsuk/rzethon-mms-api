class ReportSenderService
  attr_reader :report, :current_node

  def initialize(report)
    @report = report
    @current_node = Node.current
  end

  def self.call(*args)
    new(*args).send_report
  end

  def send_report
    if report_node then
      Rails.logger.debug "Report for message uuid: #{report.message_id} will be sent in #{time_remaning_to_next_node(report_node)} seconds to #{report_node.host}"
      SendReportWorker.perform_in(time_remaning_to_next_node(report_node).seconds, report_node.host, report.id)
    end
  end

  private

  def time_remaning_to_next_node(target_node)
    distance = NodesDistanceCalculator.call(current_node, target_node)
    DistanceToTimeConverter.new(distance).time.presence / report.speed_factor || 1
  end

  def report_node
    @report_node ||= begin
      Node.where(name: PathService.new.paths[report.source][1]).take
    end
  end
end
