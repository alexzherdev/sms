class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.string :name
      t.integer :school_year
      t.integer :hours_per_week

      t.timestamps
    end
  end

  def self.down
    drop_table :subjects
  end
end
