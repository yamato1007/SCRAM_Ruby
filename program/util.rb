module Util

    #2重の配列を平坦化する
    def self.flatten(xs) 
        xs.reduce([]) do |acc, x|
            acc.concat x
        end
    end

end

class Point
    attr_accessor :x
    attr_accessor :y
    def initialize(x,y)
        @x = x
        @y = y
    end
    def length 
        Math.sqrt(x*x + y*y)
        (x*x + y*y)
    end
    def +(other)
        Point.new(self.x + other.x, self.y + other.y)
    end
    def -(other)
        Point.new(self.x-other.x, self.y-other.y)
    end
    def distance(other)
        (self - other).length
    end
    def to_s
        "(#{x}, #{y})"
    end
    alias row x
    alias column y
end


