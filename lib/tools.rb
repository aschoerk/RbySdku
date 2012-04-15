# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'set'

module RbySdku
  module Tools
    def RbySdku.index2Block(dim, ix)
      return ix / (dim * dim)
    end

    def RbySdku.index2Row(dim, ix)
      offset = dim ** 3
      return ((ix / offset) * dim) + ((ix / dim) % dim)
    end

    def RbySdku.index2Col(dim, ix)
      blocksize = dim * dim
      return (ix % dim) + (dim * ((ix / blocksize) % dim))
    end

    def RbySdku.blockIndices(dim, block)
      res = []
      e = dim * dim
      (0...e).each {
        |x|
        res << (block * e) + x
      }
      return res
    end

    def RbySdku.colIndices(dim, col)
      res = []
      e = dim * dim
      (0...e).each { |x| res <<
          (((col / dim) + (dim * (x / dim)))*e) +
          (((x % dim) * dim) + (col % dim))
      }
      return res
    end

    def RbySdku.rowIndices(dim, row)
      res = []
      e = dim * dim
      (0...e).each {|x|
        res << ((e * ((dim * (row / dim)) + (x / dim))) +
          ((x % dim) + (dim * (row % dim))))
      }
      return res
    end

    def RbySdku.dimByArray(array)
      Math.sqrt(Math.sqrt(array.count())).floor
    end


#    def RbySdku.initIndices(maxdim)
#      result=[]
#      (2..maxdim).each { |dim|
#        maxcoord = dim * dim
#        createIndices = lambda { |creator|
#            presult = []
#            (0...maxcoord).each { |coord| presult << creator.call(coord) }
#            return presult;
#          }
#        result << [createIndices.call(lambda { |coord| rowIndices(dim, coord)}),
#                   createIndices.call(lambda { |coord| colIndices(dim, coord)}),
#                   createIndices.call(lambda { |coord| blockIndices(dim, coord)})]
#      }
#      return result
#    end

   


    def RbySdku.initIndicesByYield(maxdim)
      result=[]
      (2..maxdim).each { |dim|
        maxcoord = dim * dim
        def RbySdku.createIndices(maxcoord)
          presult = []
          (0...maxcoord).each { |coord| presult << (yield coord) }
          presult;
        end
        result << [createIndices(maxcoord) { |coord| rowIndices(dim, coord)},
                   createIndices(maxcoord) { |coord| colIndices(dim, coord)},
                   createIndices(maxcoord) { |coord| blockIndices(dim, coord)}]
      }
      return result
    end

    @@Indices = RbySdku.initIndicesByYield(4)

    def RbySdku.colIndicesC(dim, col)
      return @@Indices[dim - 2][1][col]
    end
    def RbySdku.blockIndicesC(dim, block)
      return @@Indices[dim - 2][2][block]
    end
    def RbySdku.rowIndicesC(dim, row)
      return @@Indices[dim - 2][0][row]
    end
    def RbySdku.coord2Index(dim, col, row)
      return colIndicesC(dim,col)[row];
    end

    def RbySdku.joinIndicesAtPos(dim,pos)
      a = rowIndicesC(dim,index2Row(dim,pos))
      b = colIndicesC(dim,index2Col(dim,pos))
      c = blockIndicesC(dim,index2Block(dim,pos))
      return (a | b | c).to_set
    end

    def RbySdku.joinIndices(dim)
      len = dim ** 4
      return (0...len).map {|ix| joinIndicesAtPos(dim, ix)}
    end

    @@joinedIndices=[[],[], RbySdku.joinIndices(2),
                            RbySdku.joinIndices(3),RbySdku.joinIndices(4)]


    def RbySdku.joinIndexArrays(dim)
      len = dim ** 4
      return (0...len).map {|ix| joinIndicesAtPos(dim, ix).to_a}
    end

    @@joinedIndexArray=[[],[], RbySdku.joinIndexArrays(2),
                               RbySdku.joinIndexArrays(3),
                               RbySdku.joinIndexArrays(4)]

    def RbySdku.checkArea(dim, indices, val, sudokuArray)
  # indexes describe positions in sudokuArray either horizontally, vertically or block-area.
  # returns true if val can be inserted into this area <==> no value at one of indexes equals val"
      areasize = dim * dim
      (0...areasize).each { |i|
        if (sudokuArray[indices[i]] == val)
          return false
        end
      }
      return true
    end

    def RbySdku.singlePosCheck(dim, currentIndex, sudokuArray)
  # find out which values can be inserted at currentIndex in sudokuArray without directly invalidating the puzzle
  # returns an array containing two values: the currentIndex and an array containing all the at this position obviously valid values,
  # value of sudokuArray at position currentIndex must be zero."
      res = []
      if (sudokuArray[currentIndex] != 0)
        return res
      else
        rowI = rowIndicesC(dim,index2Row(dim, currentIndex))
        colI = colIndicesC(dim,index2Col(dim, currentIndex))
        blockI = blockIndicesC(dim,index2Block(dim, currentIndex))
        e = dim * dim
        (1..e).each { |val|
          if (checkArea(dim,rowI,val,sudokuArray) and
              checkArea(dim,colI,val,sudokuArray) and
              checkArea(dim,blockI,val,sudokuArray))
            res << val
          end
        }
      end
      if (res.count > 0)
        return [currentIndex,res]
      else
        return []
      end
    end

    def RbySdku.createPbls(dim, sudokuArray)
  # gets all possible values for each empty (0) places and add these together with the position in the resultarray.
  # the resultarray is sorted so the position with the shortest arrays, the least possibilities are at the beginning."
      arraysize = dim ** 4
      res = []
      (0...arraysize).each do |a|
        res1 = singlePosCheck(dim, a, sudokuArray)
        if (res1.count > 0)
          res << res1
        end
      end
      if (res.count > 0)
        res = res.sort { |a,b| a[1].count <=> b[1].count }
        return res;
      else
        return sudokuArray
      end
    end

    def RbySdku.complexityByPbls(pbls)
      if (pbls != nil and pbls.count > 0)
        return pbls.map { |l| l[1].count }.inject(0) { |res, a| res += a }
      else
        return 0
      end
    end

    def RbySdku.pblsComplexity(dim, array)
      pbls = createPbls(dim, array)
      return complexityByPbls(pbls)
    end


    def RbySdku.complexity2ByPbls(pbls)
      if (pbls != nil and pbls.count > 0)
        return pbls.map { |l| l[1].count ** 2  }.inject(0) { |res, a| res += a }
      else
        return 0
      end
    end

    def RbySdku.pblsComplexity2(dim, array)
      pbls = createPbls(dim, array)
      return complexity2ByPbls(pbls)
    end


    def RbySdku.extractSingles(pbls)
      return pbls.inject([]) { |res,el| 
        if (el[1].count == 1); res << el; else; res; end; }
    end

    def RbySdku.extractDoubles(pbls)
      return pbls.inject([]) { |res,el| 
        if (el[1].count == 2); res << el; else; res; end  }
    end

    def RbySdku.extractNonSingles(pbls)
      return pbls.inject([]) { |res,el| 
        if (el[1].count > 1); res << el; else; res; end  }
    end
  end
end

def cljfilter(coll)
  res = []
  coll.each { |e|
    if (yield e)
      res << e
    end  
  }
  return res
end

#def cljremove(coll)
#  res = []
#  coll.each { |e|
#    if not (yield e)
##      res << e
#    end
#  }
#  return res
#end

def max(a,b)
  if a > b
    return a
  else
    return b
  end
end
