module Testowl
  class Tester

    def initialize(runner, reason)
      @runner = runner
      @reason = reason
      @files_list = []
    end

    def add(files)
      array = [files].flatten
      @files_list << array unless array.empty?
    end

    def identifier
      Digest::MD5.hexdigest @files_list.flatten.join
    end

    def run
      test_count = 0
      fail_count = 0
      seconds = 0
      files_run = []
      begin
        @files_list.each do |files|
          puts "Running #{files.inspect}"
          files_run += files
          result = @runner.run(files)
          test_count += result[0]
          fail_count += result[1]
          seconds += result[2]
          break if fail_count > 0
        end
        if @files_list.empty?
          puts "No tests found"
        elsif test_count == 0
          Growl.grr "Empty Test", "No tests run", seconds, :error, files_run, @reason, identifier
          return false
        elsif fail_count > 0
          Growl.grr "Fail", "#{fail_count} out of #{test_count} test#{'s' if test_count > 1} failed :(", seconds, :failed, files_run, @reason, identifier
          return false
        else
          Growl.grr "Pass", "All #{test_count} example#{'s' if test_count > 1} passed :)", seconds, :success, files_run, @reason, identifier
          return true
        end
      rescue => exc
        Growl.grr "Exception", exc.message, nil, :error, files_run, @reason, identifier
      end
    end

  end
end