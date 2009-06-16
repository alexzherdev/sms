require 'test_helper'

class StudentGroupTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert StudentGroup.new.valid?
  end
end
