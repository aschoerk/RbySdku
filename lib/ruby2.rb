#!/usr/bin/ruby -w
# webwhoami - show web user's id


#

## My second ruby program

#

#


# Process.setrlimit(Process::RLIMIT_AS,38080384,38080384)
##  Process.setrlimit(Process::RLIMIT_STACK,1000000,1000000)
require 'cgi'
require 'tools'
require 'print'
require 'solver'
#require 'pry'


@@examples = []

File.open(File.dirname(__FILE__) + "/examples.txt","r") { |f|
   f.each_line { |line|
     splitted = line.gsub(/[\[\]]/,"").split(" ")
     @@examples << splitted.map! { |item| item.to_i(10)  }
   }
}

def blocksRowFromSudoku(cgi, ixstart, dim, calcElement)
  return cgi.tr  {
    s = ""
    (0...dim).each { |x|
      s << calcElement.call(cgi, ixstart + x)
    }
    s + "\n"
  }
end

def blockFromSudoku(cgi, blockx, blocky, dim, calcElement)
  qdim = dim * dim
  ixstart = blocky * dim * qdim + blockx * qdim
  resblock = cgi.table('border' => "0", 'cellpadding' => "2") {
    res = ""
    (0...dim).each  { |y|
      res << blocksRowFromSudoku(cgi, ixstart + (dim * y), dim, calcElement)
    }
    res
  }
  resblock
end

def blockedRowFromSudoku(cgi, blocky, dim, calcElement)
  resrow = cgi.tr {
    res = ""
    (0...dim).each { |blockx|
      res << cgi.td {
        blockFromSudoku(cgi,blockx,blocky,dim,calcElement)
      }
    }
    res
  }
  resrow
end

def blockedTableFromSudoku(cgi,dim, calcElement)
  resTable = cgi.table('id'=>"sudokutable", 'border' => "1", 'cellpadding' => "1",
  'cellspacing' => "1") {
    rows = ""
    (0...dim).each { |blocky|
      rows << blockedRowFromSudoku(cgi,blocky,dim,calcElement)
    }
    rows
  }
  # GC.start
  resTable
end



def createCalcNormalElement(sudokuArray, checksolution, solution, clear)
 if clear
    return lambda { |cgi, ix|
      return cgi.td {
        params = {'type'=>"text", 'size'=>"1", 'onchange'=>"sdkuchg2(this)"}
        params['name'] = "@" + ix.to_s
        cgi.input(params)
      }
    }
 else
   return lambda { |cgi, ix|
     params = {'type'=>"text", 'size'=>"1", 'onchange'=>"sdkuchg2(this)"}
     val = sudokuArray[ix]
     return cgi.td  {
       params['name'] = "@" + ix.to_s
       if val == 0
         params['onchange'] = "sdkuchg(this)"
       else
         params['readonly'] = "true"
         params['value'] = val.to_s
       end
       cgi.input(params)
     }
   }
 end
end

def encodeArray(solution)
  res = (solution.map { |el| el.to_s }).inject("") { |str,el| str+"a"+el }
  res[1..res.length-1]
end

def decodeArray(astr)
  return nil if astr == nil
  res = astr.split("a").map { |el| el.to_i }
  res.delete(0)
  return res
end


def examplParam(cgi)
  val = cgi["example"]
  res = 0
  if val == ""
    res = rand @@examples.count
  else
    res = val.to_i
  end
  return res
end


def arrayFromParams(cgi)
  res = []
  (0..80).each { res << 0  }
  cgi.keys.each { |key|
    # $stderr.puts "\"" + key + "\""
    if key[0..0] == "@"
      ix = key[1..4].to_i
      $stderr.puts key + ix.to_s
      res[ix] = cgi[key].to_i
    end    
  }
  # $stderr.puts "arrayFromParams: " + res.inspect
  return res
end



@@solver = RbySdku::Solver.new

ParamStruct = Struct.new('ParamInfo',:sudokuarray,:solver,:hints,:currentexample,:solvres,:check,:clear)

def interpretParams(cgi)
  examplep = examplParam(cgi)
  example =
    case
    when (cgi.key?("next") and (examplep < (@@examples.count - 1)))
      examplep + 1
    when (cgi.key?("prev") and (examplep > 0))
      examplep - 1
    else
      examplep
    end
  loadexample = ((not (cgi.key?("check") or cgi.key?("clear") or cgi.key?("solver"))) \
    and (cgi.key?("next") or cgi.key?("prev") or not cgi.key?("example")))

  havesolution = (not loadexample and cgi.key?("solution") and not cgi.key?("clear") and not cgi.key?("check"))
  sudokuArray = if loadexample
    @@examples[example]
  else
    arrayFromParams(cgi)
  end
  if loadexample or not havesolution
    res = @@solver.solveByPoss(RbySdku.dimByArray(sudokuArray), sudokuArray).result
  else
    res = decodeArray(cgi["solution"])
  end

  return ParamStruct.new(
    sudokuArray,
    cgi.key?("solver"),
    cgi.key?("hints"),
    example,
    res,
    cgi.key?("check"),
    cgi.key?("clear")
  )
end

def calcNewArray(pInfo)
  puts pInfo
  if pInfo.solver
    return @@solver.solveByPoss(RbySdku.dimByArray(pInfo.sudokuarray), pInfo.sudokuarray).result
  else
    return pInfo.sudokuarray
  end
end


cgi = CGI.new("html3")  # add HTML generation methods
cgi.out{
  pInfo = interpretParams(cgi)
  solution = pInfo.solvres
  dim = RbySdku.dimByArray(solution)
  qdim = dim * dim
  $stderr.puts solution.inspect
  array = calcNewArray(pInfo)
  ways = "solvres.ways"
  example = pInfo.currentexample
  #CGI.pretty(
  # binding.pry
  cgi.html{
    cgi.head{ "\n"+
        cgi.title{"This Is a Test with"} +
              cgi.style('type'=>"text/css") {
      "\nbody { background-color:#CCCCCC;
               margin-left:100px; }
        \n* { color:blue; }
        \nh1 { font-size:300%;
             color:#FF0000;
             font-style:italic;
             border-bottom:solid thin black; }
        \np,li  { font-size:110%;
             line-height:140%;
             font-family:Helvetica,Arial,sans-serif;
             letter-spacing:0.1em;
             word-spacing:0.3em; }
        \ntd input { color:black; background-color:#FFFFCC; font-style:normal; size=\"1\" }
        \n.wrong { color:red; background-color:#FFCCCC; }
        \n.emptycell { background-color:#FFFFFF; }
        \n.ok { color:blue; background-color:#CCCCCC; }
        \n.buttons { color:grey; background-color:#CCCCCC; }

        \n#sudokutable { margin-left:50px}
        \n#navi { float:left; margin: 0 0 1em 1em; padding: 0 }
        \n#table { float:right }

        "
      } +
      cgi.script('type' => "text/javascript") {
        "\nfunction sdkuchg (obj) {
          // alert(\"extracted: \" + document.sudokuform.solution.value.split(\"a\")[obj.name.substring(1)]);
          if (0 > obj.value || #{qdim} < obj.value || obj.value != document.sudokuform.solution.value.split(\"a\")[obj.name.substring(1)])
            {// alert(\"wrong input: \" + obj.value);
            obj.className = \"wrong\";}
          else obj.className=\"\";
        }" +
        "\nfunction sdkuchg2 (obj) {
          if (0 > obj.value || #{qdim} < obj.value)
            {// alert(\"wrong input: \" + obj.value);
            obj.className = \"wrong\";}
          else obj.className=\"\";
        }\n"
      }
    } +
    cgi.body{ "\n" +
      cgi.h1 {"Welcome to Sudoku"} +
      cgi.form('name'=>"sudokuform") {
        # solvres = @@solver.solveByPoss(dim, @@examples[1])
        "\n"+
       #cgi.p {
       #   "infos: AS: " + Process.getrlimit(Process::RLIMIT_AS)[0].to_s + " Stack: " + Process.getrlimit(Process::RLIMIT_STACK)[0].to_s
       # } +
       cgi.table {
        cgi.div('id' => "navi") {
           cgi.input('type'=>"hidden",'name'=>"solution",'value'=>encodeArray(solution)) +
           cgi.input('type'=>"hidden",'name'=>"ways",'value'=>ways.to_s) + cgi.br +
           cgi.input('type'=>"submit",'name'=>"check",'value'=>"check") + cgi.br +
           cgi.input('type'=>"submit",'name'=>"clear",'value'=>"clear") + cgi.br +
           "hints: " + 
           cgi.input('type'=>"checkbox",'name'=>"hints",
            'value'=>"", 'checked'=>(pInfo.hints ? "true" : nil)) + cgi.br +
           cgi.input('type'=>"submit",'name'=>"solver",'value'=>"solve") + cgi.br +
           cgi.p {
             cgi.input('type'=>"submit",'name'=>"next",'value'=>"next") + cgi.br +
             cgi.input('type'=>"submit",'name'=>"prev",'value'=>"prev") + cgi.br +
             "No: " +
               cgi.input('type'=>"text",'name'=>"example",'value'=>example.to_s, 'size'=>"3") +
               cgi.p("Complexity:")
           }
        } +
        cgi.div('id' => "table") {
         blockedTableFromSudoku(cgi,dim,createCalcNormalElement( array, true, solution, pInfo.clear))

        }
       } +

        
       if pInfo.hints
           cgi.p() {
             pbls = RbySdku.createPbls(dim, array)
             "\nhints, complexity: " + RbySdku.complexityByPbls(pbls).to_s +
             "/" + RbySdku.complexity2ByPbls(pbls).to_s + "\n" +
             RbySdku.printPbls(dim,pbls)
             # $stderr.puts pbls.inspect
           }
       else
         ""
       end
      }
    }
  }
  #)
}
