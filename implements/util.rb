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
        Math.sqrt(@x*@x + @y*@y)
    end
    def +(other)
        Point.new(@x + other.x, @y + other.y)
    end
    def -(other)
        Point.new(@x - other.x, @y - other.y)
    end
    def distance(other)
        (self - other).length
    end
    def to_s
        "(#{@x}, #{@y})"
    end
    alias row x
    alias column y
end

class Point3
    attr_accessor :x
    attr_accessor :y
    attr_accessor :z
    def initialize(x,y,z)
        @x = x
        @y = y
        @z = z
    end
    def length
        Math.sqrt(@x*@x + @y*@y + @z*@z)
    end
    def +(o)
        Point3.new(@x+o.x,@y+o.y,@z+o.z)
    end
    def -(o)
        Point3.new(@x-o.x,@y-o.y,@z-o.z)
    end
    def distance(other)
        (self - other).length
    end
    def to_s
        "(#{@x}, #{@y}, #{@z})"
    end
end
