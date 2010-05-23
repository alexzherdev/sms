class Mailer < ActionMailer::Base
  def student_weekly_results(student, marks)
    recipients  'li0liq@yandex.ru' #student.parent_email
    from        'school.management.system@yandex.ru'
    subject     "фывфыв"
    body        :student => student,
                :marks => marks
    content_type "text/html"
  end
end
