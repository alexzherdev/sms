module CommaSeparatedIds
  def self.included(base)
    base.extend(self)
  end
  
  def accepts_comma_separated_ids_for(association)
    method_name = "comma_separated_#{association.to_s.singularize}_ids="
    define_method method_name do |ids|
      ids = ids.split(",").collect(&:to_i)
      self.send(association.to_s.singularize + "_ids=", ids)
    end
  end
end

ActiveRecord::Base.send(:include, CommaSeparatedIds)