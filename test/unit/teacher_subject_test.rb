require 'test_helper'

class TeacherSubjectTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert TeacherSubject.new.valid?
  end
end
