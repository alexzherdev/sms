# coding: utf-8

Factory.define :person do |u|
  u.first_name 'Александр'
  u.middle_name 'Сергеевич'
  u.last_name 'Пушкин'
  u.birth_date DateTime.now
  u.sex "male"
end

Factory.define :year do |y|
  y.start_year 2010
  y.end_year 2011
end

Factory.define :acl_action do |aa|
  aa.name "Роли"
end


