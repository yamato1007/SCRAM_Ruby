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
end

class Hungarian
    def initialize(matrix)
        @matrix = matrix
    end

    def calc
        puts "\n\n--------------------"
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
        matrix.to_a.map{|l|l.map{|e|e.nil? ? '' : e}}.each {|l| p l}
        puts "\n"
        makeZeroFunc = lambda do |list|
            list.map {|e| e - list.min}
        end
        matrix = matrix.mapRows &makeZeroFunc
        matrix.to_a.map{|l|l.map{|e|e.nil? ? '' : e}}.each {|l| p l}
        puts "\n"
        matrix = matrix.mapColumns &makeZeroFunc 
        matrix.to_a.map{|l|l.map{|e|e.nil? ? '' : e}}.each {|l| p l}
        puts "\n"
        matrix
    end

    def moreMakeZero(matrixOrigin)
        puts "\n\n--------moreMakeZero--------"
        matrix = matrixOrigin.clone
        delTimes = matrix.clone.map {|e| 0}

        matrix.to_a.map{|l|l.map{|e|e.nil? ? '' : e}}.each {|l| p l}
        puts "\n"

        while matrix.any? {|e| e == 0} do
            rcPoint = matrix.getRowColumnPoint do |acc,l|
                l.count(0) > acc.count(0) || (l.count(0) == acc.count(0) && l.count(nil) > acc.count(nil))
            end
            matrix = matrix.mapLine(rcPoint) {|e| nil}
            matrix.to_a.map{|l|l.map{|e|e.nil? ? '' : e}}.each {|l| p l}
            puts "\n"
            delTimes = delTimes.mapLine(rcPoint) {|n| n+1}
        end
        puts "\n"
        matrix.to_a.map{|l|l.map{|e|e.nil? ? '' : e}}.each {|l| p l}
        puts "\n"
        min = matrix.min
        matrix = matrix.map{|e| e - min}
        matrix.to_a.map{|l|l.map{|e|e.nil? ? '' : e}}.each {|l| p l}
        puts "\n"
        matrix = matrix.zipWith(matrixOrigin){|x,y| x || y}.zipWith(delTimes){|x,t| t == 2 ? x + min : x} 
        matrix.to_a.map{|l|l.map{|e|e.nil? ? '' : e}}.each {|l| p l}
        puts "\n"
        matrix
    end


    def assignMatch(matrix)
        puts "\n\n--------assignMatch--------"
        matrix = matrix.clone
        match = {}
        size = matrix.row_size

        matrix = matrix.map {|e| e == 0 ? e : nil}
        matrix.to_a.map{|l|l.map{|e|e.nil? ? '' : e}}.each {|l| p l}
        puts "\n"
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
            puts point
            match[point.row] = point.column
            matrix = matrix.mapCrossLine(point) {|e| nil}
            matrix.to_a.map{|l|l.map{|e|e.nil? ? '' : e}}.each {|l| p l}
            puts "\n"
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
#matrix = SCRAM::edgesToMatrix(robots,positions)
#hungarian = Hungarian.new(matrix)
#p hungarian.calc
