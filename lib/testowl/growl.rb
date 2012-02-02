module Testowl
  module Growl

    Growlnotify = "growlnotify"

    def self.grr(title, message, seconds, status, files, suffix, identifier)
      project = File.expand_path(".").split("/").last
      growlnotify = `which #{Growlnotify}`.chomp
      if growlnotify == ''
        if @warning_done
          puts "Skipping growl"
        else
          puts "If you install #{Growlnotify} you'll get growl notifications. See the README."
          @warning_done = true
        end
      else
        message_lines = [message.gsub("'", "`")]
        message_lines << sprintf("(%0.1f seconds)", seconds) if seconds
        message_lines << "#{files.map{|file| file.sub(/^spec\/[^\/]*\//, '').sub(/_test.rb$/, '')}.join("\n")}\n#{suffix}"
        message_lines << identifier
        options = []
        options << "-n Watchr"
        options << "--message '#{message_lines.join("\n\n")}'"
        options << "--image '#{image_path(status)}'"
        options << "--identifier #{identifier}" # (used for coalescing)
        title = "TestOwl #{title} (#{project})"
        system %(#{growlnotify} #{options.join(' ')} '#{title}' &)
        puts message
      end
    end

    def self.image_path(name)
      File.dirname(__FILE__) + "/../../images/#{name}.png"
    end

  end
end