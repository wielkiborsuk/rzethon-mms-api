class NodeService
  attr_reader :host

  def initialize(host)
    @host = host
  end

  def propagate(nodes)
    client.post("/propagations") do |request|
      request.body = { nodes: nodes }
    end
  end

  def submit(node)
    client.post("/submissions") do |request|
      request.body = { node: node }
    end
  end

  def send_message(message)
    client.put("/messages/deliver") do |request|
      request.body = { message: message }
    end
  end

  def send_report(report)
    client.put("/messages/report") do |request|
      request.body = { report: report }
    end
  end

  private

  def client
    @client ||= begin
      Faraday.new(url: host) do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
  end
end
