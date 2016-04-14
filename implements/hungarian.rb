require "matrix"
require "./util.rb"

class Vector
    def each
        self.size.times do |e|
            unless self[e].nil? then
                yield self[e]
            else
                self[e]
            end
        end
    end
    def count(n)
        c = 0
        self.size.times do |i|
            c = self[i] == n ? c+1 : c
        end
        c
    end
    def map
        v = [] 
        (0...self.size).each do |e|
            unless self[e].nil? then
                v.push (yield self[e])
            else
                v.push self[e]
            end
        end
        Vector.elements(v,false)
    end
end
module RowColumn
    R = :R
    C = :C
end
class RCPoint
    attr_accessor :rc
    attr_accessor :n
    def initialize(rc,n)
        @rc = rc
        @n = n
    end
    def to_s
        "(" << @rc.to_s << ":" << @n.to_s << ")"
    end
end
class Array
    def reduce1(&block)
        tmp = self.clone
        head = tmp.shift
        tmp.reduce(head) &block
    end
    alias foldl reduce
    alias foldl1 reduce1
end

class Matrix
    def []=(i,j,x)
        @rows[i][j]=x
    end
    def all?(&block)
        self.row_vectors.map {|v| v.all? &block}.all?
    end
    def any?(&block)
        self.row_vectors.map {|v| v.any? &block}.any?
    end
    def each(&block)
        self.row_vectors.each {|r| r.each &block} 
    end
    def min
        mins = Vector.elements(self.row_vectors.map {|r| r.min}).min
    end 
    def map(&block)
        Matrix.rows((self.row_vectors.map {|r| r.map &block} ), false)
    end
    def mapRows(&block)
        Matrix.rows((self.row_vectors.map &block), false)
    end
    def mapColumns(&block)
        Matrix.columns(self.column_vectors.map &block)
    end
    def mapLine(rcPoint,&block)
        m = self.clone 
        if rcPoint.rc == RowColumn::R then
            m.column_size.times do |i|
                m[rcPoint.n,i] = !m[rcPoint.n,i].nil? ? block.call(m[rcPoint.n,i]) : nil
            end
        else
            m.row_size.times do |i|
                m[i,rcPoint.n] = !m[i,rcPoint.n].nil? ? block.call(m[i,rcPoint.n]) : nil
            end
        end
        m
    end
    def mapCrossLine(point,&block)
        m = self.mapLine(RCPoint.new(RowColumn::R,point.row)) {|e| block.call e}
        m.row_size.times do |i| 
            if i != point.row && !m[i,point.column].nil? then
                m[i,point.column] = block.call(m[i,point.column]) 
            end
        end
        m
    end
    def zip(other)
        m = self.clone
        m.row_size.times do |r|
            m.column_size.times do |l|
                m[r,l] = [m[r,l], other[r,l]]
            end
        end
        m
    end
    def zipWith(other,&block)
        self.zip(other).map {|e| block.call(e[0], e[1])}
    end
    def getRowColumnPoint(&block)
        rowColumn = self.row_vectors + self.column_vectors
        head = rowColumn.shift
        point = rowColumn.foldl([0,head,1]) do |acc, l|
            if block.call(acc[1],l) then
                acc[0] = acc[2]
                acc[1] = l
            end
            acc[2] += 1
            acc
        end[0]
        point < self.row_size ? RCPoint.new(RowColumn::R, point) : RCPoint.new(RowColumn::C, point - self.row_size)
    end 
    def getRowColumn(rcPoint)
        if rcPoint.rc == RowColumn::R then
            self.row_vectors[rcPoint.n]
        else
            self.column_vectors[rcPoint.n]
        end 
    end
    def index_with_RCPoint(rcPoint,n)
        p = self.getRowColumn(rcPoint).to_a.index(n)
        unless p.nil? then
            rcPoint.rc == RowColumn::R ? Point.new(rcPoint.n, p) :  Point.new(p, rcPoint.n)
        else
            nil
        end 
    end
    def to_s
        length = self.reduce(0) do |acc, e|
            e.nil? || acc >= e.to_s.length ? acc : e.to_s.length
        end
        self.to_a.reduce(""){|acc,l|
            acc << (l.reduce("[") do |acc,e|
                str = (e.nil? ? "" : e.to_s)
                lengthDist = length - str.length 
                acc << str << " "*lengthDist << ", "
            end).chop.chop << "]\n"
        } << "\n"
    end
end

class Hungarian
    attr_reader :sumCost
    def initialize(matrix)
        @matrix = @matrixOrigin = matrix
        @sumCost = nil
    end

    def calc
        puts "--------------------"
        puts "-----Hungarian------"
        puts "--------------------\n"
        @matrix = makeZero(@matrix)
        match = assignMatch(@matrix)
        while match.nil? do
            @matrix = moreMakeZero(@matrix)
            match = assignMatch(@matrix)
        end
        match 
    end

    def makeZero(matrix)
        puts "\n\n--------makeZero--------"
        matrix = matrix.clone
        puts matrix
        makeZeroFunc = lambda do |list|
            list.map {|e| e - list.min}
        end
        matrix = matrix.mapRows &makeZeroFunc
        puts matrix
        matrix = matrix.mapColumns &makeZeroFunc 
        puts matrix
        matrix
    end

    def moreMakeZero(matrixOrigin)
        puts "\n\n--------moreMakeZero--------"
        matrix = matrixOrigin.clone
        delTimes = matrix.clone.map {|e| 0}
        puts matrix 
        while matrix.any? {|e| e == 0} do
            rcPoint = matrix.getRowColumnPoint do |acc,l|
                l.count(0) > acc.count(0) || (l.count(0) == acc.count(0) && l.count(nil) > acc.count(nil))
            end
            matrix = matrix.mapLine(rcPoint) {|e| nil}
            delTimes = delTimes.mapLine(rcPoint) {|n| n+1}
            puts "Hide : " << rcPoint.to_s
            puts matrix
        end
        min = matrix.min
        matrix = matrix.map{|e| e - min}
        puts "subtruction : -" << min.to_s
        puts matrix
        matrix = matrix.zipWith(matrixOrigin){|x,y| x || y}
        puts "restoration" 
        puts matrix
        matrix = matrix.zipWith(delTimes){|x,t| t == 2 ? x + min : x} 
        puts "addition : +" << min.to_s
        puts matrix
        matrix
    end


    def assignMatch(matrix)
        puts "\n\n--------assignMatch--------"
        matrix = matrix.clone
        match = {}
        size = matrix.row_size
        @sumCost = 0

        matrix = matrix.map {|e| e == 0 ? e : nil}
        puts matrix
        size.times do 
            if(matrix.all? {|e| e == nil})
                return nil
            end
            rcPoint = matrix.getRowColumnPoint do |acc,l|
                lZero = l.count(0)
                accZero = acc.count(0)
                accZero == 0 || (lZero != 0 && lZero < accZero)
            end
            point = matrix.index_with_RCPoint(rcPoint,0) 
            puts "Matching : " << point.to_s
            match[point.row] = point.column
            @sumCost += @matrixOrigin[point.row,point.column]
            matrix = matrix.mapCrossLine(point) {|e| nil}
            puts matrix
        end
        match = match.sort{|(k1,v1),(k2,v2)| k1 <=> k2}
        match.each {|k,v| puts (k.to_s + " -> " + v.to_s)} 
        match
    end
end


####test hungarian##k
#matrix = Matrix[[5,7,6,4,9],[3,10,5,5,7],[4,9,7,6,10],[5,9,6,5,9],[4,8,5,6,9]]
#matrix = Matrix[[0,0,3,2],[3,5,1,0],[5,9,0,3],[2,2,0,1]]
#hungarian = Hungarian.new(matrix)

#require "./scram"
#robots = [[1,1],[0,1],[4,0],[6,0],[0,2],[3,2]].map{|e|Point.new(e[0],e[1])}.map{|e|Agent.new e}
#positions = [[0,0],[1,0],[4,2],[5,2],[6,2],[5,1]].map{|e|Point.new(e[0],e[1])}.map{|e|Position.new e}
#matrix = SCRAM::nodesToMatrix(robots,positions)
#hungarian = Hungarian.new(matrix)
#hungarian.calc.each{|k,v|puts Edge.new(robots[k],positions[v])}
#p hungarian.sumCost

