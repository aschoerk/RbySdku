#!/usr/bin/ruby -w
## My first ruby program
#

#

## Declare our salutation


require 'cgi'
require 'etc'
require 'tools'
require 'solver2'

GC.start

# Prepare statements

#
# Process.setrlimit(Process::RLIMIT_AS,18080384,18080384)
# puts "$RUBY_VERSION"

# @@solver = RbySdku::Solver.new
cgi = CGI.new("html3")  # add HTML generation methods
cgi.out{
  cgi.html{
    cgi.head{ "\n"+cgi.title{"This Is a Test"} } +
    cgi.body{ "\n"+
      # Process.getrlimit("AS").to_s +
      cgi.form{"\n"+
        cgi.hr +
        Process.getrlimit(Process::RLIMIT_AS)[1].to_s +
        RUBY_VERSION.to_s + 
        cgi.h1 { "A Form: " } + "\n"+
        cgi.textarea("get_text") +"\n"+
        cgi.br +
        cgi.submit
      }
    }
  }
}


