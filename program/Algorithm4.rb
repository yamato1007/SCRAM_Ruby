require "./util.rb"
require "./scram.rb"

class Algorithm4
    def initialize (r,p)
        #エージェント群
        @robots = r
        #タスク群
        @positions = p
        #エージェントからタスクへの全ての組み合わせ
        @edges = Util::flatten ( @robots.map do |a|
            @positions.map do |p|
                Edge.new(a,p)
            end
        end)
        #タスク割り当て済みのエージェントの集合
        @matchedRobots = []
        #割当を許されたタスク割当
        @allowedEdges = []
    end

    #許された割当の中で、
    #タスクNode、もしくはnilを返しうる
    def flood(curNode, prevNode)
        curNode.visited = true
        curNode.previous = prevNode

        #カレントノードがタスクであり、許されている割当ての中でカレントノードから出発する割当がなければ(カレントノードがすでに割り当て済みのタスクでなければ)、カレントノードを返す
        if (@positions.include? curNode) && @allowedEdges.all? {|e| e.start != curNode} then
            return curNode
        end

        #カレントノードから出発し、到達先が未到達であるような、許された割当があれば、コストが大きい順にその全てについて、
        @allowedEdges.select do |e|
            e.start == curNode && !e.end.visited
        end.each do |e|
            val = flood(e.end,e.start)
            if val != nil then
                return val
            end
        end

        return nil 
    end


    #割り当て済みのエージェントを除き、ノードの状態を初期化する
    def resetFlood
        (([].concat @robots).concat @positions).each do |n|
            n.visited = false
            n.previous = nil
        end
        (@robots - @matchedRobots).each do |a|
            print "can match? : "
            puts a 
            p = flood(a, nil);
            unless p.nil? 
                return p
            end
        end
        return nil
    end


    def reversePath(node)
        puts "Matched!"
        while node.previous != nil do
            @allowedEdges.select do |e|
                #e.start == node && e.end == node.previous
                e.end == node && e.start == node.previous
            end.each do |e|
                e.reverseDirection
                if e.start.class == Position
                    puts e
                end
            end
            node = node.previous
        end
        return node
    end

    def calc
        puts "---------------------"
        puts "-----Algorithm4------"
        puts "---------------------\n"
        #コストの昇順にソートされたタスク割当の配列
        edgeQ = @edges.sort do |e1,e2|
            (e1.distance) <=> (e2.distance)
        end
        #最も大きい距離を持つ割当
        #これを順々に大きくしていくことで、割当を進めていく
        longestEdge = nil

        #全ての割当が終わるまでループ
        (1..(@robots.length)).each do 
            matchedPosition = nil
            while matchedPosition.nil? do
                longestEdge = edgeQ.shift
                print "\nadd longestEdge : "
                puts longestEdge
                @allowedEdges << longestEdge
                matchedPosition = resetFlood()
            end
            matchedRobot = reversePath matchedPosition
            @matchedRobots.push matchedRobot
        end
        puts "\n\nMatched Pathes"
        puts @allowedEdges.select{|e|e.start.class == Position}.map{|e|e.clone.reverseDirection}
        puts "\n\nLongest Edge"
        puts longestEdge
        puts "\n\n"
        
        return longestEdge 
    end
end 


####test algorithm4###
#robots = [[1,1],[0,1],[4,0],[6,0],[0,2],[3,2]].map{|e|Point.new(e[0],e[1])}.map{|e|Agent.new e}
#positions = [[0,0],[1,0],[4,2],[5,2],[6,2],[5,1]].map{|e|Point.new(e[0],e[1])}.map{|e|Position.new e}
#algorithm4 = Algorithm4.new(robots,positions)
#algorithm4.calc
#
