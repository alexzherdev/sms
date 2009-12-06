require File.dirname(__FILE__) + '/../profile_test_helper'
require  'ruby-prof'
class GeneratorTest < ActiveSupport::TestCase
  include RubyProf::Test
  
  def test_generation_time
    RubyProf.start

    sg = Schedule::Generator.new ClassRoom.all, StudentGroup.all, Subject.all, LessonTime.all, TeacherSubject.all
    items = sg.generate_schedule
    result = RubyProf.stop

    printer = RubyProf::GraphHtmlPrinter.new(result)
    printer.print(File.new("test.html"))
        
  end
end   
