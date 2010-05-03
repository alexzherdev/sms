namespace :sms do
  namespace :db do
    task :fill => [:empty_all, :populate] 
  
    task :empty_all => :environment do
      ScheduleItem.destroy_all
      TeacherSubject.destroy_all
      Subject.destroy_all  
      StudentGroup.destroy_all  
      ClassRoom.destroy_all  
      Person.destroy_all  
      Role.destroy_all
      AclAction.destroy_all
    end
    
    task :populate do
      create_settings
      acl_actions = create_acl_actions
      roles = create_roles
      assign_acl_actions
      groups = create_groups
      class_rooms, room_map = create_rooms_and_map
      subject_ids = create_subject_ids(room_map)
      teachers = create_teachers
      create_teacher_subjects(teachers)
      admin = User.create :login => "qwe", :password => "123qwe", :password_confirmation => "123qwe", :email => "qwe@asdasd.ru", :first_name => "first", :last_name => "last", :birth_date => DateTime.now, :home_address => "qwe", :role_id => Role.admin.id, :patronymic => "patronymic", :sex => "male"
      admin.save
    end
    
    task :fill_acl_actions => :environment do
      AclAction.destroy_all
      create_acl_actions
      assign_acl_actions
    end
    
    def create_settings
      Settings["short_break"] = 10
      Settings["long_break"] = 20
      Settings["lessons_start"] = Time.utc(2010,02,02,8,0,0)
      Settings["lesson_length"] = 45
    end
    
    def create_acl_actions
      AclAction.create ACL_ACTIONS
    end
    
    def create_roles
      ROLES.each do |role|
        Role.create :name => role
      end
    end
    
    def create_groups
      groups = []
      Subject::SCHOOL_YEARS.each do |year|
        LETTERS.each do |letter|
          group = StudentGroup.create :year => year, :letter => letter
          groups << group
        end
      end
      groups
    end
    
    def assign_acl_actions
      Role.admin.acl_actions << AclAction.find_by_name("users")
      Role.admin.acl_actions << AclAction.find_by_name("roles")
    end
    
    def create_rooms_and_map
      class_rooms = []
      room_map = {}
      for i in 1..FLOOR_COUNT do
        for j in 1..ROOMS_PER_FLOOR do
          class_room = ClassRoom.create :number => (i.to_s + (j < 10 ? "0" : "") + j.to_s)
          class_rooms << class_room
          room_map[class_room.number.to_sym] = class_room
        end
      end
      return class_rooms, room_map
    end
    
    def create_subject_ids(room_map)
      subject_ids = []
      Subject::SCHOOL_YEARS.each do |year|
        subject_no = 0
        subjects = []
        SUBJECT_NAMES.each do |subject_name|
          subjects << Subject.new(:name => subject_name, :year => year, :hours_per_week => 4)
        end
        for i in 1..FLOOR_COUNT do
          for j in 1..ROOMS_PER_FLOOR do
            room_no = i.to_s + (j < 10 ? "0" : "") + j.to_s
            subjects[subject_no].class_rooms << room_map[room_no.to_sym]
            subject_no += 1
            if subject_no >= SUBJECT_NAMES.length
              subject_no = 0
            end
          end
        end
        subjects.each do |subject|
          subject.save
          subject_ids << subject.id
        end
      end
      subject_ids
    end
    
    def create_teachers
      teachers = []
      TEACHERS.each_with_index do |teacher_name, index|
        teacher = Teacher.create :birth_date => DateTime.now, :email => "teacher#{index}@asdasd.ru", 
          :first_name => teacher_name.second.split.first, :last_name => teacher_name.first,
          :patronymic => teacher_name.second.split.second, :login => "teacher#{index}", 
          :password => "password", :password_confirmation => "password", :role_id => Role.teacher.id,
          :sex => teacher_name[2]          
        teachers << teacher
      end
      teachers
    end
    
    def create_teacher_subjects(teachers)
      j = 0
      Subject::SCHOOL_YEARS.each do |year|
        year_groups = StudentGroup.by_year(year)
        year_subjects = Subject.by_year(year)
        year_groups.each do |group|
          year_subjects.each do |subject|
            teacher = teachers[j]
            TeacherSubject.create :student_group => group, :teacher => teacher, :subject => subject
            j += 1
            if j >= teachers.length
              j = 0
            end
          end
        end
      end
    end
    
    ACL_ACTIONS = [
      { :name => "users", :title => "Пользователи" },
      { :name => "roles", :title => "Роли" },
      { :name => "news/new", :title => "Управление новостями" },
      { :name => "years", :title => "Учебные годы и четверти" },
      { :name => "time_table_items", :title => "Расписание звонков" },
      { :name => "class_rooms", :title => "Аудитории" },
      { :name => "students", :title => "Ученики" },
      { :name => "student_groups", :title => "Классы" },
      { :name => "subjects", :title => "Предметы" },
      { :name => "teacher_subjects", :title => "Предметы учителей" },
      { :name => "schedule", :title => "Расписание занятий" },
      { :name => "register", :title => "Журналы" },
      { :name => "comments", :title => "Управление комментариями" }
    ]
    
    LETTERS = ["A", "B", "C"]
    SUBJECT_NAMES = ["Математика", "Русский язык", "Белорусский язык", 
            "Физкультура", "Физика", "Химия", 
            "История", "Английский язык", "Биология"]
    FLOOR_COUNT = 3
    ROOMS_PER_FLOOR = 15
    ROLES = [
      "Администратор",
      "Учитель",
      "Родитель",
      "Методист",
      "Директор"
    ]
    
    TEACHERS = [
      ["Абрамишвили", "Мария Гурамовна", "female"],
      ["Августинович", "Глория Олеговна", "female"],
      ["Авеева", "Ева Владимировна", "female"],
      ["Аверина", "Ирина Егоровна", "female"],
      ["Агапова", "Нина Фёдоровна", "female"],
      ["Агуреева", "Полина Владимировна", "female"],
      ["Адельгейм", "Тамара Фридриховна", "female"],
      ["Азарова", "Анна Александровна", "female"],
      ["Азарх-Опалова", "Евгения Эммануиловна", "female"],
      ["Акимова", "Софья Павловна", "female"],
      ["Акиньшина", "Оксана Александровна", "female"],
      ["Аксюта", "Татьяна Владимировна", "female"],
      ["Акулова", "Ирина Григорьевна", "female"],
      ["Акулова", "Тамара Васильевна", "female"],
      ["Алабина", "Инна Ильинична", "female"],
      ["Александрова", "Марина Андреевна", "female"],
      ["Алексахина", "Анна Яковлевна", "female"],
      ["Алентова", "Вера Валентиновна", "female"],
      ["Алимова", "Матлюба Фархатовна", "female"],
      ["Алфёрова", "Ирина Ивановна", "female"],
      ["Вдовина", "Наталья Геннадьевна", "female"],
      ["Вележева", "Лидия Леонидовна", "female"],
      ["Великанова", "Елена Сергеевна", "female"],
      ["Волчек", "Галина Борисовна", "female"],
      ["Вертинская", "Анастасия Александровна", "female"],
      ["Вертинская", "Марианна Александровна", "female"],
      ["Вилкова", "Екатерина Николаевна", "female"],
      ["Вилкова", "Таисия Александровна", "female"],
      ["Виноградова", "Мария Сергеевна", "female"],
      ["Вознесенская", "Анастасия Валентиновна", "female"],
      ["Воилкова", "Валентина Дмитриевна", "female"],
      ["Волкова", "Екатерина Юрьевна", "female"],
      ["Волкова", "Ольга Владимировна", "female"],
      ["Дамскер", "Юлия Иосифовна", "female"],
      ["Данилина", "Эльвира Игоревна", "female"],
      ["Данилова", "Наталья Юрьевна", "female"],
      ["Дапкунайте", "Ингеборга Эдмундовна", "female"],
      ["Дворжецкая", "Нина Игоревна", "female"],
      ["Дезмари", "Диана Игоревна", "female"],
      ["Демидова", "Алла Сергеевна", "female"],
      ["Державина", "Наталья Владимировна", "female"],
      ["Джербинова", "Юлия Георгиевна", "female"],
      ["Джураева", "Тамара Николаевна", "female"],
      ["Димова", "Анна Олеговна", "female"],
      ["Дитковските", "Агния Олеговна", "female"],
      ["Добровольская", "Евгения Владимировна", "female"],
      ["Догилева", "Татьяна Анатольевна", "female"],
      ["Дольникова", "Теона Валентиновна", "female"],
      ["Доронина", "Татьяна Васильевна", "female"],
      ["Дорохина", "Александра Митрофановна", "female"],
      ["Дорохина", "Оксана Сергеевна", "female"],
      ["Юганова", "Алла Сергеевна", "female"],
      ["Юдина", "Зоя Борисовна", "female"],
      ["Юдина", "Ирина Юрьевна", "female"],
      ["Юнгер", "Елена Владимировна", "female"],
      ["Юнникова", "Наталья Александровна", "female"],
      ["Соколова", "Галина Михайловна", "female"],
      ["Соколова", "Зинаида Сергеевна", "female"],
      ["Соколова", "Ирина Леонидовна", "female"],
      ["Соколова", "Любовь Сергеевна", "female"],
      ["Солдатова", "Наталья Эдуардовна", "female"],
      ["Соловей", "Елена Яковлевна", "female"],
      ["Соломина", "Варвара Михайловна", "female"],
      ["Соломина", "Екатерина Сергеевна", "female"],
      ["Сотникова", "Вера Михайловна", "female"],
      ["Сотничевская", "Софья Владимировна", "female"],
      ["Спивак", "Эмилия Семёновна", "female"],
      ["Столповская", "Ольга Борисовна", "female"],
      ["Стрелкова-Оболдина", "Инга Петровна", "female"],
      ["Стрельская", "Варвара Васильевна", "female"],
      ["Стрепетова", "Полина Антипьевна", "female"],
      ["Стриженова", "Екатерина Владимировна", "female"],
      ["Стриженова", "Любовь Васильевна", "female"],
      ["Стриженова", "Марианна Александровна", "female"],
      ["Судейкина", "Вера Артуровна", "female"],
      ["Судзиловская", "Олеся Ильинична", "female"],
      ["Сутулова", "Ольга Александровна", "female"],
      ["Сухаревская", "Лидия Петровна", "female"],
      ["Суюншалина", "Бибигуль Актановна", "female"],
      ["Сёмина", "Тамара Петровна", "female"],
      ["Сёмкина", "Мария Рафаиловна", "female"]
    ]
  end
end