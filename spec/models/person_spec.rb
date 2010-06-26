# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Person do
  before :each do
    @person = Factory(:person)
  end
  
  it "should format full name properly with and without middle name" do
    @person.full_name.should == "Пушкин Александр Сергеевич"
    @person.full_name(false).should == "Пушкин Александр"
  end
  
  it "should format initials properly" do
    @person.full_name_abbr.should == "Пушкин А. С."
  end
  
end