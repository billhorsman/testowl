module Testowl
  class RspecRunner

    def run(files)
      results = runDirectly(files)
      count_match = /(\d+)\sexamples?,\s(\d+)\sfailures?/.match(results)
      timing_match = /Finished\sin\s([0-9\.]*)\sseconds/.match(results)
      if count_match && timing_match
        test_count = count_match[1].to_i
        fail_count = count_match[2].to_i
        timing = timing_match[1].to_f
        return test_count, fail_count, timing
      else
        raise "Problem interpreting result. Please check the terminal output."
      end
    end
      
    def runDirectly(files)
      results = TestOwl::Teeio.new
      results.run "rspec -c #{files.join(" ")}"
      results.output
    end

  end
end