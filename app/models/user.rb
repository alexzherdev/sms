class User < Person  
  has_one :mailbox, :class_name => "Mailbox::Mailbox"
  belongs_to :role
  
  validates_presence_of :role_id
  
  after_create :create_mailbox
  after_save :assign_children
  
  attr_accessor :child_ids
  
  acts_as_authentic
  
  accepts_comma_separated_ids_for :children
  
  def can_access?(signature)
    role.acl_actions.any? { |act| act.name == signature }    
  end
  
  #  Дети этого пользователя.
  #
  def children
    Student.scoped(:conditions => [ "parent1_id = ? or parent2_id = ?", self.id, self.id ])
  end

  #  Возвращает классы, журналы которых этот пользователь может просматривать (реализация для родителя).
  #
  def student_groups_for_register
    children.collect(&:student_group).compact.uniq
  end
  
  #  Возвращает предметы, которые может просматривать этот пользователь в журнале данного класса (реализация для родителя).
  #
  #  * <tt>group</tt>:: Класс.
  #
  def subjects_for_register(group)
    Subject.find_all_by_year(group.year).sort
  end
  
  #  Может ли пользователь редактировать журнал - нет (реализация для родителя).
  #
  def can_edit_register?
    false
  end
  
  protected
  
  def assign_children
    Student.update_all({ :parent1_id => self.id }, { :id => self.child_ids })
  end

end