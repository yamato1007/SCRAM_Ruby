require "./hungarian.rb"
require "./scram.rb"
require "./util.rb"


class Algorithm2
    def initialize(robots,positions) 
        @robots = robots
        @positions = positions
        @edges = Util::flatten ( @robots.map do |a|
            @positions.map do |p|
                Edge.new(a,p)
            end
        end)
    end
    def calc
        puts "---------------------"
        puts "-----Algorithm2------"
        puts "---------------------\n"
        edgesSorted = @edges.sort do |e1,e2|
            (e1.distance) <=> (e2.distance)
        end
        lastDistance = -1
        rank = currentIndex = 0
        repetition = 1
        power2 = 2
        edgesSorted.each do |e|
            if e.distance > lastDistance then
                rank = currentIndex
                lastDistance = e.distance
                repetition = 1
                power2 = 2
                currentIndex += 1
            else 
                repetition += 1
                if repetition >= power2
                    currentIndex += 1
                    power2 *= 2
                end
            end
            e.distance = 2**rank
        end
        match = Hungarian.new(SCRAM::edgesToMatrix(@robots,@positions,@edges)).calc.map{|k,v|[@robots[k],@positions[v]]}.to_h
        puts "\n\nMatching"
        match.each {|k,v| puts (k.to_s + " -> " + v.to_s)} 
        match
    end
end


###Test Algorithm2###
#robots = [[1,1],[0,1],[4,0],[6,0],[0,2],[3,2]].map{|e|Point.new(e[0],e[1])}.map{|e|Agent.new e}
#positions = [[0,0],[1,0],[4,2],[5,2],[6,2],[5,1]].map{|e|Point.new(e[0],e[1])}.map{|e|Position.new e}
#Algorithm2.new(robots,positions).calc
