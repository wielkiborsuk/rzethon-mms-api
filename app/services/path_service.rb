class PathService
  attr_reader :paths, :graph

  def initialize()
    @paths = JSON.parse(Redis.current.get('paths') || "{}")
    if @paths.blank?
      recalculate
    end
  end

  def recalculate
    node_name = Redis.current.get('node_name')

    @paths = Hash[ Node.all.collect { |n|
      [n.name, Dijkstra.call(node_name, n.name)]
    } ]
    Redis.current.set('paths', @paths.to_json)
    @paths
  end
end
