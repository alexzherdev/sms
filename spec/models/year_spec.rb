require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Year do
  before :each do
    @year = Factory(:year)
  end
  
  it "should format name properly" do
    @year.full_name.should == "2010 - 2011"
  end
  
  it "should add the next year whether there are years present or not" do
    @year2 = Year.add
    @year2.start_year.should == 2011
    @year2.end_year.should == 2012
    
    Year.destroy_all
    
    @new_year = Year.add
    @new_year.start_year.should == Time.now.year
    @new_year.end_year.should == Time.now.year + 1
  end
  
end