class NodeSubmissionWorker
  include Sidekiq::Worker
  sidekiq_options dead: false
  @@semafor = Mutex.new

  def perform(base_host, current_host, name)
    @@semafor.synchronize do
      return if not ActiveRecord::Base.connection.data_source_exists? 'nodes'
      return if Node.where(name: name).any?
      location = NodeLocationService.new(name).get_location

      node_params = {
        host: current_host,
        name: name
      }.merge(location.attributes)

      node = Node.where(name: node_params[:name]).first_or_initialize
      node.assign_attributes(node_params)
      node.save!

      client = NodeService.new(base_host)
      client.submit(node.as_json(except: :id))
    end
  end
end
