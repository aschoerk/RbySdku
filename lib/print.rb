# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'tools'

module RbySdku
  module Print
    def RbySdku.printSudokuLine(dim, rowIndexes, sudokuarray)
      (0...(dim*dim)).each { |col| puts sudokuarray[rowIndexes[col]].to_s + " "  }
    end

    def RbySdku.printSudoku(sudokuArray)
      dim = RbySdku.dimByArray(sudokuArray)
      (0...(dim*dim)).each { |row| printSudokuLine(dim,RbySdku.rowIndicesC(dim,row),sudokuArray);puts }
      puts
    end

    def RbySdku.printPbls(dim, pbls)
      res = ""
      c = pbls.count
      if (c > 0)
        pbls.each { |el|
          ix=el[0]
          row = RbySdku.index2Row(dim,ix)
          col = RbySdku.index2Col(dim,ix)
          res << " | " + (col + 1).to_s + "/" + (row+1).to_s + ": "+el[1].inspect
        }        
      end
      return res
    end
#     puts "ready running"
      
  end
end
