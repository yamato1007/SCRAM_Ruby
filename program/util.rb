module Util

    #2重の配列を平坦化する
    def self.flatten(xs) 
        xs.reduce([]) do |acc, x|
            acc.concat x
        end
    end

end

