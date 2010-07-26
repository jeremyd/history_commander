require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HistoryCommander" do
  it "is cool" do
    EM.run do
      HistWatch.start
    end
  end
end
