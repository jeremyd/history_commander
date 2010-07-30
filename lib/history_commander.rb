require 'rubygems'
require 'json'
require 'eventmachine'
require 'eventmachine-tail'
require 'mq'
require 'uuidtools'
require 'mash'

class HistoryCommander < EventMachine::FileTail
  attr_accessor :uuid
  attr_accessor :pause

  def safe_path
    "#{path}_safe"
  end

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

  def receive_data(data)
    @buffer.extract(data).each do |line|
      payload = { :uuid => @uuid, 
                  :message => line,
                  :host => @host,
                  :user => @user }
                  
      @global_history_fanout.publish(payload.to_json)
    end
  end
  
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

class HistWatch
  def self.start(file = File.join(File.expand_path('~'), ".bash_history"))
    @hist_file_watch = EventMachine::file_tail(file, HistoryCommander)
  end

  def self.stop
    EM.stop
  end
end
