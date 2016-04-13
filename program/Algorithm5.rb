require "./hungarian.rb"
require "./Algorithm4.rb"
require "./scram.rb"


class Algorithm5
    def initialize(robots,positions) 
        @robots = robots
        @positions = positions
    end
    def calc
        longesetEdge = Algorithm4.new(@robots,@positions).calc
        minimalEdges = SCRAM::nodesToMatrix(@robots,@positions).map{|x|x <= longesetEdge.distance ? x : nil}.map{|x|x*x}
        match = Hungarian.new(minimalEdges).calc.map{|k,v|[@robots[k],@positions[v]]}.to_h
        match.each {|k,v| puts (k.to_s + " -> " + v.to_s)} 
    end
end


###Test Algorithm5###
#robots = [[1,1],[0,1],[4,0],[6,0],[0,2],[3,2]].map{|e|Point.new(e[0],e[1])}.map{|e|Agent.new e}
#positions = [[0,0],[1,0],[4,2],[5,2],[6,2],[5,1]].map{|e|Point.new(e[0],e[1])}.map{|e|Position.new e}
#robots = [[1,2],[-1,5],[3,2]].map{|x|Point.new(x[0],x[1])}.map{|x| Agent.new x}
#positions = [[5,3],[0,4],[1,-1]].map{|x|Point.new(x[0],x[1])}.map{|x| Position.new x}
#algorithm5 = Algorithm5.new(robots,positions).calc

