# These fix 1.8.7 test/unit results where a DRbUnknown is returned because the testdrb client doesn't have the classes
# in its local namespace.  (See issue #2)
unless RUBY_VERSION =~ /^1\.9/
  # MiniTest is Ruby 1.9, and the classes below only exist in the pre 1.9 test/unit
  require 'test/unit/testresult'
  require 'test/unit/failure'
end
require 'drb'

module Testowl
  class TestUnitRunner

    def run(files)
      results = begin
        runDrb(files)
      rescue
        puts "Drb not available. Running tests directly instead."
        runDirectly(files)
      end
      puts "Done"
      count_match = /(\d+)\sassertions?,\s(\d+)\sfailures?,\s(\d+)\serrors?/.match(results)
      timing_match = /Finished\sin\s([0-9\.]*)\sseconds/.match(results)
      puts count_match
      puts timing_match
      if count_match && timing_match
        test_count = count_match[1].to_i
        fail_count = count_match[2].to_i + count_match[3].to_i # let's lump errors and failures together
        timing = timing_match[1].to_f
        return test_count, fail_count, timing
      else
        raise "Problem interpreting result. Please check the terminal output."
      end
    end

    def runDrb(files)
      DRb.start_service("druby://127.0.0.1:0") # this allows Ruby to do some magical stuff so you can pass an output stream over DRb.
      test_server = DRbObject.new_with_uri("druby://127.0.0.1:8988")
      results = TestOwl::Teeio.new
      test_server.run(files, results, results)
      results.output
    end

    def runDirectly(files)
      results = TestOwl::Teeio.new
      results.run "ruby #{files.join(' ')}"
      results.output
    end

  end

end