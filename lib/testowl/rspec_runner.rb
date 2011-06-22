module Testowl
  class RspecRunner

    def run(files)
      results = runDirectly(files)
      lines = results.output.split("\n")
      exception_message = lines.detect{|line| line =~ /^Exception encountered/ }
      counts = lines.detect{|line| line =~ /(\d+)\sexamples?,\s(\d+)\sfailures?/ }
      if counts
        test_count, fail_count = counts.split(',').map(&:to_i)
        timing = lines.detect{|line| line =~ /Finished\sin/}
        timing = timing.sub(/Finished\sin/, '').strip if timing
        return test_count, fail_count, timing
      else
        if exception_message
          raise exception_message
        else
          raise "Problem interpreting result. Please check the terminal output."
        end
      end
    end
      
    def runDirectly(files)
      results = TestOwl::Teeio.new
      results.run "rspec -c #{files.join(" ")}"
      results.output
    end

  end
end