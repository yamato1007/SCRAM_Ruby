require "./scram"
require "./util"

#定数群、あるいは入力値
robots = [[1,1],[0,1],[4,0],[6,0],[0,2],[3,2]].map{|e|Point.new(e[0],e[1])}.map{|e|Agent.new e}
positions = [[0,0],[1,0],[4,2],[5,2],[6,2],[5,1]].map{|e|Point.new(e[0],e[1])}.map{|e|Position.new e}


puts "-------Test Algorith 2-------"
puts "-------      MMDR     -------"
puts "-------     O(n^5)    ------- "
require "./Algorithm2.rb"
Algorithm2.new(robots,positions).calc



#puts "-------Test Algorith 5-------"
#puts "-------  MMD + MSD^2  -------"
#puts "-------     O(n^3)    ------- "
#require "./Algorithm5.rb"
#Algorithm5.new(robots,positions).calc



