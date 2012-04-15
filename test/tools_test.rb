# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'set'
require 'tools'

module RbySdku
  module Tools
    class ToolsTest < Test::Unit::TestCase
      include RbySdku::Tools
      
      def testIndex2Block
        assert_equal(0, (RbySdku.index2Block 3,  0))
        assert_equal(0, (RbySdku.index2Block 3,  1))
        assert_equal(1, (RbySdku.index2Block 3, 10))
        assert_equal(8, (RbySdku.index2Block 3, 80))
        assert_equal(1, (RbySdku.index2Block 3,  9))
        assert_equal(0, (RbySdku.index2Block 3,  8))
        assert_equal(1, (RbySdku.index2Block 3, 17))
        assert_equal(2, (RbySdku.index2Block 3, 18))
        assert_equal(8, (RbySdku.index2Block 3, 72))
        assert_equal(7, (RbySdku.index2Block 3, 71))
      end
      def testIndex2Row
        assert_equal(0, (RbySdku.index2Row 3,  0))
        assert_equal(0, (RbySdku.index2Row 3,  1))
        assert_equal(1, (RbySdku.index2Row 3, 3))
        assert_equal(8, (RbySdku.index2Row 3, 80))
        assert_equal(7, (RbySdku.index2Row 3, 77))
        assert_equal(0, (RbySdku.index2Row 3,  9))
        assert_equal(0, (RbySdku.index2Row 3, 18))
        assert_equal(2, (RbySdku.index2Row 3, 17))
        assert_equal(3, (RbySdku.index2Row 3, 27))
        assert_equal(4, (RbySdku.index2Row 3, 30))
      end

      def testIndex2Col
        assert_equal(0, (RbySdku.index2Col 3,  0))
        assert_equal(1, (RbySdku.index2Col 3,  1))
        assert_equal(0, (RbySdku.index2Col 3,  3))
        assert_equal(8, (RbySdku.index2Col 3, 80))
        assert_equal(8, (RbySdku.index2Col 3, 77))
        assert_equal(3, (RbySdku.index2Col 3, 9))
        assert_equal(6, (RbySdku.index2Col 3, 18))
        assert_equal(5, (RbySdku.index2Col 3, 17))
        assert_equal(0, (RbySdku.index2Col 3, 27))
        assert_equal(0, (RbySdku.index2Col 3, 30))
      end

      def testBlockIndices
        assert_equal([0, 1, 2, 3, 4, 5, 6, 7, 8], (RbySdku.blockIndices 3, 0))
        assert_equal([72, 73, 74, 75, 76, 77, 78, 79, 80], (RbySdku.blockIndices 3, 8))
      end

      def testColIndices
        assert_equal([0, 3, 6, 27, 30, 33, 54, 57, 60], (RbySdku.colIndices 3, 0))
        assert_equal([20, 23, 26, 47, 50, 53, 74, 77, 80], (RbySdku.colIndices 3, 8))
      end

      def testRowIndices
        assert_equal([0, 1, 2, 9, 10, 11, 18, 19, 20], (RbySdku.rowIndices 3, 0))
        assert_equal([60, 61, 62, 69, 70, 71, 78, 79, 80], (RbySdku.rowIndices 3, 8))
      end

      def testdimByArray
        assert_equal 2, RbySdku.dimByArray(0...16)
        assert_equal 3, RbySdku.dimByArray(0...81)
      end

      def testInitIndices
        ix = @@Indices # RbySdku.initIndices(3)
        assert_equal(3, ix.count)
        assert_equal(3, ix[0].count)
        assert_equal(3, ix[1].count)
        assert_equal(4, ix[0][0].count)
        assert_equal(4, ix[0][1].count)
        assert_equal(4, ix[0][2].count)
        assert_equal(9, ix[1][0].count)
        assert_equal(9, ix[1][1].count)
        assert_equal(9, ix[1][2].count)
        assert_equal(RbySdku.rowIndices(2, 0), ix[0][0][0])
        assert_equal(RbySdku.colIndices(2, 0), ix[0][1][0])
        assert_equal(RbySdku.blockIndices(2, 0), ix[0][2][0])
        assert_equal(RbySdku.rowIndices(2, 3), ix[0][0][3])
        assert_equal(RbySdku.colIndices(2, 3), ix[0][1][3])
        assert_equal(RbySdku.blockIndices(2, 3), ix[0][2][3])
      end

      def testCoordToIndex
        assert_equal(0,RbySdku.index2Col(3, RbySdku.coord2Index(3,0,0)))
        assert_equal(1,RbySdku.index2Col(3, RbySdku.coord2Index(3,1,0)))
        assert_equal(2,RbySdku.index2Col(3, RbySdku.coord2Index(3,2,0)))
        assert_equal(8,RbySdku.index2Col(3, RbySdku.coord2Index(3,8,8)))
        assert_equal(7,RbySdku.index2Col(3, RbySdku.coord2Index(3,7,7)))
        assert_equal(7,RbySdku.index2Col(3, RbySdku.coord2Index(3,7,0)))
        assert_equal(5,RbySdku.index2Col(3, RbySdku.coord2Index(3,5,0)))
        assert_equal(5,RbySdku.index2Col(3, RbySdku.coord2Index(3,5,8)))
        assert_equal(7,RbySdku.index2Col(3, RbySdku.coord2Index(3,7,8)))
        assert_equal(0,RbySdku.index2Row(3, RbySdku.coord2Index(3,0,0)))
        assert_equal(0,RbySdku.index2Row(3, RbySdku.coord2Index(3,1,0)))
        assert_equal(0,RbySdku.index2Row(3, RbySdku.coord2Index(3,2,0)))
        assert_equal(8,RbySdku.index2Row(3, RbySdku.coord2Index(3,8,8)))
        assert_equal(7,RbySdku.index2Row(3, RbySdku.coord2Index(3,7,7)))
        assert_equal(0,RbySdku.index2Row(3, RbySdku.coord2Index(3,7,0)))
        assert_equal(0,RbySdku.index2Row(3, RbySdku.coord2Index(3,5,0)))
        assert_equal(8,RbySdku.index2Row(3, RbySdku.coord2Index(3,5,8)))
        assert_equal(8,RbySdku.index2Row(3, RbySdku.coord2Index(3,7,8)))
        assert_equal(8,RbySdku.index2Row(3, RbySdku.coord2Index(3,0,8)))
      end

      def testJoinedIndices
        ji = RbySdku.joinIndices(2)
        ji.each { |i| assert_equal(true,i.is_a?(Set)) }
        assert_equal([0, 1, 2, 3, 4, 5, 8, 10].to_set,ji[0])
        assert_equal([0, 1, 2, 3, 4, 5, 9, 11].to_set,ji[1])
        assert_equal([0, 1, 2, 3, 6, 7, 8, 10].to_set,ji[2])
        assert_equal([0, 1, 2, 3, 6, 7, 9, 11].to_set,ji[3])
        assert_equal([0, 1, 4, 5, 6, 7, 12, 14].to_set,ji[4])
        assert_equal([0, 1, 4, 5, 6, 7, 13, 15].to_set,ji[5])
        assert_equal([2, 3, 4, 5, 6, 7, 12, 14].to_set,ji[6])
        assert_equal([2, 3, 4, 5, 6, 7, 13, 15].to_set,ji[7])
        assert_equal([0, 2, 8, 9, 10, 11, 12, 13].to_set,ji[8])
        assert_equal([1, 3, 8, 9, 10, 11, 12, 13].to_set,ji[9])
        assert_equal([0, 2, 8, 9, 10, 11, 14, 15].to_set,ji[10])
        assert_equal([1, 3, 8, 9, 10, 11, 14, 15].to_set,ji[11])
        assert_equal([4, 6, 8, 9, 12, 13, 14, 15].to_set,ji[12])
        assert_equal([5, 7, 8, 9, 12, 13, 14, 15].to_set,ji[13])
        assert_equal([4, 6, 10, 11, 12, 13, 14, 15].to_set,ji[14])
        assert_equal([5, 7, 10, 11, 12, 13, 14, 15].to_set,ji[15])
      end
  
      def testJoinedIndexArrays
        ji = RbySdku.joinIndexArrays(2)
        ji.each { |i| assert_equal(true,i.is_a?(Array)) }
        assert_equal([0, 1, 2, 3, 4, 5, 8, 10].to_set,ji[0].to_set)
        assert_equal([0, 1, 2, 3, 4, 5, 9, 11].to_set,ji[1].to_set)
        assert_equal([0, 1, 2, 3, 6, 7, 8, 10].to_set,ji[2].to_set)
        assert_equal([0, 1, 2, 3, 6, 7, 9, 11].to_set,ji[3].to_set)
        assert_equal([0, 1, 4, 5, 6, 7, 12, 14].to_set,ji[4].to_set)
        assert_equal([0, 1, 4, 5, 6, 7, 13, 15].to_set,ji[5].to_set)
        assert_equal([2, 3, 4, 5, 6, 7, 12, 14].to_set,ji[6].to_set)
        assert_equal([2, 3, 4, 5, 6, 7, 13, 15].to_set,ji[7].to_set)
        assert_equal([0, 2, 8, 9, 10, 11, 12, 13].to_set,ji[8].to_set)
        assert_equal([1, 3, 8, 9, 10, 11, 12, 13].to_set,ji[9].to_set)
        assert_equal([0, 2, 8, 9, 10, 11, 14, 15].to_set,ji[10].to_set)
        assert_equal([1, 3, 8, 9, 10, 11, 14, 15].to_set,ji[11].to_set)
        assert_equal([4, 6, 8, 9, 12, 13, 14, 15].to_set,ji[12].to_set)
        assert_equal([5, 7, 8, 9, 12, 13, 14, 15].to_set,ji[13].to_set)
        assert_equal([4, 6, 10, 11, 12, 13, 14, 15].to_set,ji[14].to_set)
        assert_equal([5, 7, 10, 11, 12, 13, 14, 15].to_set,ji[15].to_set)
      end

      @@test2DimArray=[1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 0, 0, 0, 0]

      @@test2DimWrongArray=[1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 3, 0, 0, 0]

      @@test2DimArray4=[1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 0, 0, 0, 0]

      @@test2DimArray2=[1, 2, 3, 4, 0, 0, 1, 2, 2, 1, 4, 3, 0, 0, 0, 0]

      @@test2DimArray3=[1, 2, 4, 3, 0, 0, 1, 2, 2, 1, 3, 4, 0, 0, 0, 0]

      def testSinglePosCheck
        assert_equal([4], RbySdku.singlePosCheck(2,12, @@test2DimArray)[1])
        assert_equal(12, RbySdku.singlePosCheck(2,12,@@test2DimArray)[0])
        assert_equal([3],RbySdku.singlePosCheck(2,13,@@test2DimArray)[1])
        assert_equal(13,RbySdku.singlePosCheck(2,13,@@test2DimArray)[0])
        assert_equal([2],RbySdku.singlePosCheck(2,14,@@test2DimArray)[1])
        assert_equal(14,RbySdku.singlePosCheck(2,14,@@test2DimArray)[0])
        assert_equal([1],RbySdku.singlePosCheck(2,15,@@test2DimArray)[1])
        assert_equal(15,RbySdku.singlePosCheck(2,15,@@test2DimArray)[0])
        assert_equal([],RbySdku.singlePosCheck(2,13,@@test2DimWrongArray))
        assert_equal([],RbySdku.singlePosCheck(2,11,@@test2DimArray))
      end

      def testcreatePbls
        sorter = lambda do |a,b| a[0]<=>b[0] end
        assert_equal(([[15, [1]], [14, [2]], [13, [3, 4]],
            [12, [3, 4]], [5, [3, 4]], [4, [3, 4]]].sort(&sorter)),
          (RbySdku.createPbls(2,@@test2DimArray3).sort(&sorter))
        )

      end      
    end    
  end
end


class CljToolsTest < Test::Unit::TestCase
  def testFilter
    assert_equal([1,3], cljfilter([1,2,3,4]) {|e| e.odd? })
  end  
end
    



