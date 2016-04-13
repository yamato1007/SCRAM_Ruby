require "./scram"
require "./util"
require "./Algorithm2.rb"
require "./Algorithm3.rb"
require "./Algorithm4.rb"
require "./Algorithm5.rb"
require "./hungarian.rb"


module Test
    #定数群、あるいは入力値
    #ROBOTS = [4,2,6,3,-9,6,11,5,9,2].map{|e|Agent.new e}
    #POSITIONS = [3,5,2,7,13,3,-3,-11,-3,2].map{|e|Position.new e}
    ROBOTS = [[1,1],[0,1],[4,0],[6,0],[0,2],[3,2]].map{|e|Point.new(e[0],e[1])}.map{|e|Agent.new e}
    POSITIONS = [[0,0],[1,0],[4,2],[5,2],[6,2],[5,1]].map{|e|Point.new(e[0],e[1])}.map{|e|Position.new e}

    def self.algorithm2
        puts "-------Test Algorithm 2-------"
        puts "-------       MMDR     -------"
        puts "-------      O(n^5)    ------- "
        Algorithm2.new(ROBOTS,POSITIONS).calc
    end
    def self.algorithm3
        puts "-------Test Algorithm 3-------"
        puts "-------      MMDR      -------"
        puts "-------     O(n^4)     ------- "
        Algorithm3.new(ROBOTS,POSITIONS).calc
    end
    def self.algorithm4
        puts "-------Test Algorithm 4-------"
        puts "-------    Find MMD    -------"
        puts "-------     O(n^2)     ------- "
        Algorithm4.new(ROBOTS,POSITIONS).calc
    end
    def self.algorithm5
        puts "-------Test Algorithm 5-------"
        puts "-------   MMD + MSD^2  -------"
        puts "-------      O(n^3)    ------- "
        require "./Algorithm5.rb"
        Algorithm5.new(ROBOTS,POSITIONS).calc
    end
    def self.hungarian
        puts "-------Test Hungarian-------"
        puts "-------      MSD     -------"
        puts "-------    O(n^3)    ------- "
        require "./Algorithm5.rb"
        Hungarian.new(SCRAM::nodesToMatrix(ROBOTS,POSITIONS)).calc
    end
end

#Test.algorithm2
Test.algorithm3
#Test.algorithm4
#Test.algorithm5
#Test.hungarian


