# Teeio has two approaches to capturing output and this single class
# attempts to do both - smudged, wedged and shoved into one. The problem
# we're solving here is how to get the output from the tests streamed to
# stdout while still being able to capture the output for analysis. 
# Doing a simple backtick means that we're not able to provide feedback
# on progress until the tests are finished.
#
# If you call run then it will pipe the ouput, via tee, to a temporary
# file and then read that file to get the output.
#
# You can also pass an instance of this class for objects that expect
# stdio and it will probably work, in a duck-typing fashion. At least,
# it works with Spork - which is what we're interested in.
module TestOwl
  class Teeio

    def initialize
      @results = []
      @file = Tempfile.new('testowl')
    end

    def run(command)
      system("#{command} | tee #{@file.path}")
    end

    def write(buf)
      @results << buf
      $stdout.write buf
    end

    def puts(buf)
      @results << buf
      $stdout.puts buf
    end

    def flush
      $stdout.flush
    end

    def output
      if @results.size == 0
        IO.read(@file.path)
      else
        @results.join
      end
    end

  end
end