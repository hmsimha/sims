require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe State do
  it "should create a new instance given valid attributes" do
    Factory(:state)
  end
end
