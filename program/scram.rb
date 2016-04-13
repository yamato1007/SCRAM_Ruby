#ノード。エージェントや目的地。
class Node
    attr_accessor :visited
    attr_accessor :previous
    attr_accessor :position
    def initialize(pos) 
        @position = pos
        @previous = nil
        @visited = false
    end
    def distance(other)
        if @position.class.method_defined? "distance" then
            @position.distance other.position
        else
            (@position - other.position).abs
        end
    end
    def to_s
        @position.to_s
    end
end

class Agent < Node
    def to_s
        "A:" << @position.to_s
    end
end

class Position < Node
    def to_s
        "P:" << @position.to_s
    end
end


class Edge
    attr_accessor :start
    attr_accessor :end
    def initialize(s,e)
        @start = s
        @end = e
        @distance = nil
    end
    def reverseDirection
        tmp = @start
        @start = @end
        @end = tmp
        self
    end
    def distance=(d)
        @distance = d
    end
    def distance
        if @distance.nil? then
            @start.distance @end
        else 
            @distance
        end
    end
    def to_s
        @start.to_s << " -> " << @end.to_s + " ...... dist : #{self.distance}"
    end
end

module SCRAM
    def self.nodesToMatrix(robots,positions,&edgesFilter)
        matrix = Matrix.zero(robots.length)
        (0...robots.length).each do |i|
            (0...positions.length).each do |j|
                matrix[i,j] = robots[i].distance positions[j]
            end
        end
        unless edgesFilter.nil? then
            matrix = matrix.map { |d| (edgesFilter.call d) ? d : nil }
        end
        matrix
    end
    def self.edgesToMatrix(robots,positions,edges,&edgesFilter)
        matrix = self.edgesWithDistFuncToMatrix(robots,positions,edges,&:distance)
        unless edgesFilter.nil? then
            matrix = matrix.map { |d| (edgesFilter.call d) ? d : nil }
        end
        matrix
    end
    def self.distFuncToMatrix(robots,positions,&distFunc)
        matrix = Matrix.zero(robots.length)
        (0...robots.length).each do |i|
            (0...positions.length).each do |j|
                matrix[i,j] = distFunc.call(robots[i],positions[j])
            end
        end
        matrix
    end
    def self.edgesWithDistFuncToMatrix(robots,positions,edges,&distFunc)
        matrix = Matrix.zero(robots.length).map{|e|nil}
        ri = robots.map.with_index{|e,i|[e,i]}.to_h
        pi = positions.map.with_index{|e,i|[e,i]}.to_h
        edges.each do |e|
            matrix[ri[e.start],pi[e.end]] = distFunc.call(e)
        end
        matrix
    end
end

