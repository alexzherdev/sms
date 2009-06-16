require 'test_helper'

class StudentsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Student.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Student.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Student.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to student_url(assigns(:student))
  end
  
  def test_edit
    get :edit, :id => Student.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Student.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Student.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Student.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Student.first
    assert_redirected_to student_url(assigns(:student))
  end
  
  def test_destroy
    student = Student.first
    delete :destroy, :id => student
    assert_redirected_to students_url
    assert !Student.exists?(student.id)
  end
end
