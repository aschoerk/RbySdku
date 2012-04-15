# To change this template, choose Tools | Templates
# and open the template in the editor.
# $:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'tools'
# require 'print'

module RbySdku
  class Solver
    include RbySdku::Tools

    def initialize
      @maxresults = 50
    end
    

    Solveres = Struct.new('Solveres',:found,:result,:level,:results,:ways,:maxlevel)

    def singlePossMapper(singles, sinixs, allixs, actpos)
      pos = actpos[0]
      currpos = actpos
      if (allixs.member?(pos))
        (0...singles.count).each { |index|
          vals = currpos[1]
          if (sinixs[index].member?(pos))
            currval = singles[index][1][0]
            (newvals = vals.clone).delete(currval)
            currpos = [pos, newvals]
          end
        }
        return currpos
      else
        return actpos
      end
    end

    def checkOnePos(dim, array, pos, val)
      index_array = @@joinedIndexArray[dim][pos]
      index_array.each { |ix|
        return false if array[ix] == val
      }
      return true
    end

    def insertPos(pbls, sudokuArray, dim, pos, value)
      if (sudokuArray[pos] != 0)
        throw(:insertPosAtNotEmptyPos)
      else
        newsudoku = sudokuArray.clone
        newsudoku[pos] = value
        indices = @@joinedIndices[dim][pos]
        newpbls = []
        pbls.each { |actpos|
          if not (indices.member?(actpos[0]) and actpos[1].member?(value))
            newpbls << actpos
          else
            if pos != actpos[0]
              (newvals = actpos[1].clone).delete(value)
              if newvals.count > 0
                newpbls << [actpos[0], newvals]
              else
                return nil
              end
            end
          end
        }
        return {:array=>newsudoku, :pbls=>newpbls}
      end
    end


    def singlePosEntries(dim, singles, sudokuArray)
       array = sudokuArray.clone
       (0...singles.count).each { |index|
         pos = singles[index][0]
         currval = singles[index][1][0]
         if (array[pos] != 0)
           puts "logical error in singlePosEntries"
         else
           if (checkOnePos(dim, array,pos,currval))
             array[pos] = currval
           else
             array = nil
             break
           end
         end
       }
       return array
    end
   
    def handleSingles(pbls, sudokuArray, dim)
      singles = RbySdku.extractSingles(pbls);
      if (singles.count == 0)
        return {:array => sudokuArray, :pbls => pbls}
      else
        nonsingles = RbySdku.extractNonSingles(pbls);
        sinixs = singles.map { |el| @@joinedIndices[dim][el[0]] }
        allixs = sinixs.inject(Set.new) { |a, b| a + b }
        respbls = nonsingles.map { |el| singlePossMapper(singles, sinixs, allixs, el) }
        resarray = singlePosEntries(dim, singles, sudokuArray)
        countinvalid = (cljfilter(respbls) { |e| e[1].count == 0}).count
        if (resarray == nil or countinvalid > 0)
          return nil
        else
          return handleSingles(respbls, resarray, dim)
        end
      end
    end

    def solveResPlusMaxLevel(res, maxlevel)
      return Solveres.new(res.found, res.result, res.level, res.results,res.ways,max(res.maxlevel, maxlevel))
    end

        
    def iteratePbls1(dim, pbls, array, res, level, way)
      if (@maxresults < res.results.count)
        return res
      else
        if (pbls.count == 0)
          return Solveres.new(true,array,level,res.results<<array,res.ways<<way,max(level, res.maxlevel))
        end
        sinRes = handleSingles(pbls, array, dim)
        if sinRes == nil
          return solveResPlusMaxLevel(res, level)
        else
          curPbls = sinRes[:pbls]
          array = sinRes[:array]
          if (0 == curPbls.count)
            return Solveres.new(true,array,level,res.results<<array,res.ways<<way,max(level, res.maxlevel))
          else
            iteratePbls2(dim,curPbls,array,res,level,way)
          end
        end
      end
    end

    def iteratePbls2(dim, pbls, array, orgres, level, way)
      # pbls contains no singles, first one is to be tested
      res = orgres
      actpos = pbls[0]
      possValues = actpos[1]
      index = 0
      possValues.each { |val|
        insertRes = insertPos(pbls,array,dim,actpos[0],val)
        if insertRes == nil
          ## could not insert this possibility
          res = solveResPlusMaxLevel(res, level)
        else
          # could insert, go deeper, now also handle possibly newly created
          # singles
          res = iteratePbls1(dim, insertRes[:pbls], insertRes[:array], res, level+1, way.clone << [actpos, index])
        end
        index = index + 1
      }
      res = solveResPlusMaxLevel(res, level)
      return res
    end


    def solveByPoss(dim, array)
      pbls = RbySdku.createPbls(dim, array)
      iteratePbls1(dim, pbls, array, Solveres.new(false,nil,-1,[],[],-1), 0, [])
    end


    def sudoku(array)
      dim = RbySdku.dimByArray(array)
      res = solveByPoss(dim, array)
    end
  end
 # puts Solver.new.solveByPoss 2, [1, 0, 0, 3, 0, 0, 0, 0, 0, 1, 0, 0, 0, 3, 2, 0]
 # puts Solver.new.solveByPoss 2, [1, 0, 0, 3, 0, 0, 0, 0, 0, 1, 0, 0, 0, 3, 0, 0]

end


    

    
