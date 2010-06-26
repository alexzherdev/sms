# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AclAction do
  before :each do
    @acl_action = Factory(:acl_action)
  end
  
  it "should return the action by name" do
    action = AclAction.by_name(@acl_action.name)
    action.should_not be_blank
    action.name.should == @acl_action.name
    
  end
  
  it "should preload all actions" do
    lambda {
      act = AclAction.create :name => "Пользователи"
    }.should change { AclAction.preload.size }.by(1)
    
  end
  
end