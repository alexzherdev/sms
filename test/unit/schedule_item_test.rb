require 'test_helper'

class ScheduleItemTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert ScheduleItem.new.valid?
  end
end
