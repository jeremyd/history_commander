require 'rubygems'
require 'json'
require 'eventmachine'
require 'eventmachine-tail'
require 'mq'
require 'uuidtools'
require 'mash'
require 'fileutils'

class HistoryCommander < EventMachine::FileTail
  attr_accessor :uuid
  attr_accessor :pause

  def safe_path
    "#{path}_safe"
  end

  # path <~String> File path to monitor
  # mode <~String> Can be set to "full" for read/write mode, and any other value for write only mode.
  # startpos <~Integer> File position to start tailing the file. Default of -1 starts at the end of the file
  def initialize(path, startpos=-1, mode="full")
    super(path, startpos)
    FileUtils.cp(path, safe_path)
    @buffer = BufferedTokenizer.new
    @global_history_fanout = MQ.new.fanout('global_history')
    @uuid = UUIDTools::UUID.random_create.to_s
    @host = `hostname`.chomp
    @user = `whoami`.chomp
    @pause = false
    subscribe if mode == "full"
  end

  # Receive data from the FileTail and submit it
  # to the MQ
  def receive_data(data)
    @buffer.extract(data).each do |line|
      payload = { :uuid => @uuid, 
                  :message => line,
                  :host => @host,
                  :user => @user }
      puts "sending: #{payload}"            
      @global_history_fanout.publish(payload.to_json)
    end
  end

  # Subscribe to the global history exchange and sync the history file with any new inbound global history.  Pauses FileTail and skips the output when writing to the history file.
  def subscribe 
    @subscription = MQ.new
    @subscription.queue(@uuid).bind(@subscription.fanout('global_history')).subscribe do |result|
      x = Mash.new(JSON::parse(result))
      puts "received: #{x[:uuid]} #{x[:user]}@#{x[:host]}$ #{x[:message]}"
      if x[:uuid] != @uuid
        @pause = true
        File.open(path, "a") {|f| f.puts(x[:message])}
        skip_ahead
        @pause = false
        schedule_next_read
      end
    end
  end
end

# HistWatch is a wrapper class for starting EM and loading configuration information for History Commander
class HistWatch
  # starts
  def self.start(mode="full", file = File.join(File.expand_path('~'), ".bash_history"))
    @hist_file_watch = EventMachine::file_tail(file, HistoryCommander, -1, mode)
  end

  def self.stop
    EM.stop
  end
end
