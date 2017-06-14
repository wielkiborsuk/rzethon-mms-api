class Dijkstra

  def self.call(*args)
    new.dijkstra(*args)
  end

  def dijkstra(node1, node2)
    graph.dijkstra(node1, node2)
  end

  def graph
    @graph ||= begin
      nodes = Node.all
      graph = Graph.new nodes.collect {|n| n.name}

      nodes.each do |i|
        nodes.each do |j|
          graph.connect_mutually(i.name, j.name, NodesDistanceCalculator.call(i, j)**2)
        end
      end

      graph
    end
  end
end

class Edge
  attr_accessor :src, :dst, :length

  def initialize(src, dst, length = 1)
    @src = src
    @dst = dst
    @length = length
  end
end

class Graph < Array
  attr_reader :edges

  def initialize(*args)
    super(*args)
    @edges = []
  end

  def connect(src, dst, length = 1)
    unless self.include?(src)
      raise ArgumentException, "No such vertex: #{src}"
    end
    unless self.include?(dst)
      raise ArgumentException, "No such vertex: #{dst}"
    end
    @edges.push Edge.new(src, dst, length)
  end

  def connect_mutually(vertex1, vertex2, length = 1)
    self.connect vertex1, vertex2, length
    self.connect vertex2, vertex1, length
  end

  def neighbors(vertex)
    neighbors = []
    @edges.each do |edge|
      neighbors.push edge.dst if edge.src == vertex
    end
    return neighbors.uniq
  end

  def length_between(src, dst)
    @edges.each do |edge|
      return edge.length if edge.src == src and edge.dst == dst
    end
    nil
  end

  def dijkstra(src, dst = nil)
    distances = {}
    previouses = {}
    self.each do |vertex|
      distances[vertex] = 10000000 # Infinity
      previouses[vertex] = nil
    end

    distances[src] = 0
    vertices = self.clone

    until vertices.empty?
      nearest_vertex = vertices.min_by { |v| distances[v] }
      vertices.delete nearest_vertex

      vertices.neighbors(nearest_vertex).each do |vertex|
        alt = distances[nearest_vertex] + vertices.length_between(nearest_vertex, vertex)
        if alt < distances[vertex]
          distances[vertex] = alt
          previouses[vertex] = nearest_vertex
        end
      end
    end

    #return previouses, distances

    path = [dst]
    vertex = dst
    while previouses[vertex]
      path.unshift previouses[vertex]
      vertex = previouses[vertex]
    end

    path
  end
end
