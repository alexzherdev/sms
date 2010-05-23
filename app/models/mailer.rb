<<<<<<< HEAD:app/models/mailer.rb
class Mailer < ActionMailer::Base  def student_weekly_results(student, weekly_diary)    recipients  student.parent_email    from        'school.management.system@yandex.ru'    subject     "Успеваемость за неделю"    body        :student => student,                :marks => marks    content_type "text/html"  endend
=======
class Mailer < ActionMailer::Base  def student_weekly_results(student, weekly_diary)    recipients  student.parent_email    from        'school.management.system@yandex.ru'    subject     "тесто"    body        :student => student,                :weekly_diary => weekly_diary    content_type "text/html"  endend
>>>>>>> 938ce40... Merge branch 'master' of github.com:alexzherdev/sms:app/models/mailer.rb
