require 'rubygems'
require 'eventmachine'
require 'ruby-debug'


module HistMonitor
  def file_modified
    @last_history ||= []
    @the_history = IO.readlines(path)
    puts "history file #{path} was modified:"
    diff = @the_history - @last_history
    puts "NOOP (dupe entry)" if diff.size == 0
    puts diff.join("\n")
    @last_history = @the_history
  end
end

class HistWatch
  def self.start
    myhome = File.join(File.expand_path('~'), ".bash_history")
    hist_file_watch = EM.watch_file(myhome, HistMonitor)
  end

  def self.stop
    EM.stop
  end
end
