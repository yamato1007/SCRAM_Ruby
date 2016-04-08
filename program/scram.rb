#ノード。エージェントや目的地。
class Node
    attr_accessor :visited
    attr_accessor :previous
    attr_accessor :position
    def initialize(pos) 
        @position = pos
    end
    def distance(other)
        (@position - other.position).abs
    end
    def to_s
        @position.to_s
    end
end

class Agent < Node
    def initialize(pos) 
        @position = pos
    end
    def to_s
        "A:" << @position.to_s
    end
end

class Position< Node
    def initialize(pos) 
        @position = pos
    end
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
    end
    def reverseDirection
        tmp = @start
        @start = @end
        @end = tmp
    end
    def distance
        @start.distance @end
    end
    def to_s
        @start.to_s << " -> " << @end.to_s
    end
end


