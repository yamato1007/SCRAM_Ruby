require "./scram"
require "./Algorithm4"
require "./hungarian"
require "./util"

class Algorithm3
    def initialize(r,p)
        @robots = r
        @positions = p
    end
    def calc
        puts "---------------------"
        puts "-----Algorithm4------"
        puts "---------------------\n"
        edges = @robots.map do |a|
            @positions.map do |p|
                Edge.new(a,p)
            end
        end.flatten

        numEdgesLeft = @robots.length
        while numEdgesLeft != 0 
            minLongestEdge = Algorithm4.new(@robots, @positions, edges).calc
            costFunc = lambda do |e|
                if e.distance < minLongestEdge.distance then 0
                elsif e.distance == minLongestEdge.distance then 1
                elsif e.distance > minLongestEdge.distance then Float::INFINITY 
                end
            end
            hungarian = Hungarian.new(SCRAM::edgesWithDistFuncToMatrix(@robots,@positions,edges,&costFunc))
            match = hungarian.calc.map{|k,v|[@robots[k],@positions[v]]}.to_h
            numLongestEdge = hungarian.sumCost
            numEdgesLeft -= numLongestEdge
            edges.select! do |e| 
                match[e.start] == e.end || costFunc.call(e) == 0
            end
            edges.each do |e|
                e.distance = costFunc.call(e) == 1 ? -1 : e.distance
            end
        end
        puts "\n\nMatching"
        match.each {|k,v| puts (k.to_s + " -> " + v.to_s)} 
        match
    end
end

###Test Algorithm2###
robots = [[1,1],[0,1],[4,0],[6,0],[0,2],[3,2]].map{|e|Point.new(e[0],e[1])}.map{|e|Agent.new e}
positions = [[0,0],[1,0],[4,2],[5,2],[6,2],[5,1]].map{|e|Point.new(e[0],e[1])}.map{|e|Position.new e}
Algorithm3.new(robots,positions).calc
