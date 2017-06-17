class SendReportWorker
  include Sidekiq::Worker
  sidekiq_options dead: false

  def perform(host, report_id)
    report = Report.where(id: report_id).take
    NodeService.new(host).send_report(report.as_json)
  end
end

