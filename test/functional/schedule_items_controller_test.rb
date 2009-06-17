require 'test_helper'

class ScheduleItemsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
end
