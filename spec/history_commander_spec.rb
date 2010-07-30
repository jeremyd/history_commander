# This Spec requires a running AMQP server.
# Configure your AMQP server first and enter access information below before running this spec.

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tmpdir'

describe "HistoryCommander" do
  before(:all) do
    @watch_files = []
    2.times do |x|
      @watch_files << File.join(Dir.tmpdir, "#{x}unique-history_commander_spec_candelete")
    end
    @watch_files.each {|w| `rm #{w}; touch #{w}`}
  end
  it "runs multiple history commanders and checks for all files to contain all history" do
    EM.run do
      AMQP.start(:host => "ec2-184-72-19-157.us-west-1.compute.amazonaws.com") do
        EM.next_tick do
          @watch_files.each do |w|
            HistWatch.start(w)
          end
        end
        EM.add_timer(2) do
          @first_value = "first_command: #{rand(10000000)}"
          File.open(@watch_files.first, "a") {|f| f.puts @first_value }
        end
        EM.add_timer(3) do
          @second_value = "second_command: #{rand(10000000)}"
          File.open(@watch_files.last, "a") {|f| f.puts @second_value }
        end
        EM.add_timer(10) do
          @watch_files.each do |w|
            IO.read(w).should =~ /^#{@first_value}/
            IO.read(w).should =~ /^#{@second_value}/
          end
        end
        EM.add_timer(12) do
          EM.stop
        end
      end
    end
  end
end
