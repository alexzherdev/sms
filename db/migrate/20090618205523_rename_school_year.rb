class RenameSchoolYear < ActiveRecord::Migration
  def self.up
    rename_column :subjects, :school_year, :year
  end

  def self.down
    rename_column :subjects, :year, :school_year
  end
end
