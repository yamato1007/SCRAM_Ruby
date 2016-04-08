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

        print "Flood curNode"
        puts curNode

        #カレントノードがタスクであり、許されている割当ての中でカレントノードから出発する割当がなければ(カレントノードがすでに割り当て済みのタスクでなければ)、カレントノードを返す
        if (@positions.include? curNode) && @allowedEdges.all? {|e| e.start != curNode} then
            return curNode
        end

        #カレントノードから出発し、到達先が未到達であるような、許された割当があれば、コストが小さい順にその全てについて、
        @allowedEdges.select do |e|
            (e.start == curNode) && !(e.end.visited )
        end.each do |e|
            val = flood(e.end,e.start)
            if val != nil then
                return val
            end
        end

        #カレントノードから出発する割当がどれも許されていない
        #カレントノードから
        return nil 
    end


    #割り当て済みのエージェントを除き、ノードの状態を初期化する
    def resetFlood
        puts "\nReset"
        (([].concat @robots).concat @positions).each do |n|
            n.visited = false
            n.previous = nil
        end
        (@robots - @matchedRobots).each do |a|
            flood(a, nil);
        end
    end


    def reversePath(node)
        while node.previous != nil do
            @allowedEdges.select do |e|
                #e.start == node && e.end == node.previous
                e.end == node && e.start == node.previous
            end.each do |e|
                e.reverseDirection
            end
            node = node.previous
        end
        return node
    end



    def calc
        #コストの小さい順にソートされたタスク割当の配列
        edgeQ = @edges.sort do |e1,e2|
            (e2.distance) <=> (e1.distance)
        end
        #最もコストの掛かるタスク割当
        #これを順々に大きくしていくことで、割当を進めていく
        longestEdge = nil

        #全ての割当が終わるまでループ
        (1..(@robots.length)).each do 
            resetFlood()
            matchedPosition = nil
            while matchedPosition.nil? do
                longestEdge = edgeQ.pop
                @allowedEdges.push longestEdge
                print "\npath : "
                puts longestEdge
                matchedPosition = flood(longestEdge.end,longestEdge.start)
            end
            matchedRobot = reversePath matchedPosition
            puts Edge.new(matchedRobot , matchedPosition)
            @matchedRobots.push matchedRobot
        end
        puts "\nallowed edges\n"
        puts @allowedEdges
        return longestEdge 
    end
end 



#定数群
robots = [2,3,100].map {|x| Agent.new x}
positions = [0,1,-1].map {|x| Position.new x}
algorithm4 = Algorithm4.new(robots,positions)
puts algorithm4.calc
