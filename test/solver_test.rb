# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'solver'

class SolverTest < Test::Unit::TestCase
  @@examples = []
   File.open(File.dirname(__FILE__) + "/examples.txt","r") { |f|
     f.each_line { |line|
       splitted = line.gsub(/[\[\]]/,"").split(" ")
       @@examples << splitted.map! { |item| item.to_i(10)  }      
     }

    }
  def test_foo
    s = RbySdku::Solver.new
    index = 0
    @@examples.each { |array|
      res = s.solveByPoss(3, array)
      assert_equal 1, res.results.count, "Example no: " + index.to_s(10)
      index += 1
    }   
  end
end
