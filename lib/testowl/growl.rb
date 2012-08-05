module Testowl
  module Growl

    Growlnotify = "growlnotify"
    TerminalNotifier = "terminal-notifier"

    def self.grr(title, message, seconds, status, files, suffix, identifier)
      with_terminal_notifier(title, message, seconds, status, files, suffix, identifier) ||
        with_growl(title, message, seconds, status, files, suffix, identifier)
    end

    def self.with_terminal_notifier(title, message, seconds, status, files, suffix, identifier)
      project = File.expand_path(".").split("/").last
      terminal_notifier = `which #{TerminalNotifier}`.chomp
      if terminal_notifier == ''
        if @tn_warning_done
          puts "Skipping terminal notifier"
        else
          puts "If you install #{TerminalNotifier} you'll get notifications. Trying growl next. See the README."
          @tn_warning_done = true
        end
        false
      else
        message_lines = [message.gsub("'", "`")]
        message_lines << sprintf("(%0.1f seconds)", seconds) if seconds
        message_lines << "#{files.map{|file| file.sub(/^spec\/[^\/]*\//, '').sub(/_test.rb$/, '')}.join("\n")}\n#{suffix}"
        message_lines << identifier
        options = []
        options << "-message '#{message_lines.join("\n\n")}'"
        options << "-group #{identifier}" # (used for coalescing)
        options << "-title 'TestOwl #{title} (#{project})'"
        system %(#{terminal_notifier} #{options.join(' ')} &)
        puts message
        true
      end
    end

    def self.with_growl(title, message, seconds, status, files, suffix, identifier)
      project = File.expand_path(".").split("/").last
      growlnotify = `which #{Growlnotify}`.chomp
      if growlnotify == ''
        if @g_warning_done
          puts "Skipping growl"
        else
          puts "If you install #{Growlnotify} you'll get growl notifications. See the README."
          @g_warning_done = true
        end
        false
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
        true
      end
    end

    def self.image_path(name)
      File.dirname(__FILE__) + "/../../images/#{name}.png"
    end

  end
end