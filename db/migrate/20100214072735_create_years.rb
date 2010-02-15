class CreateYears < ActiveRecord::Migration
  def self.up
    create_table :years do |t|
      t.integer :start_year
      t.integer :end_year

      t.timestamps
    end
  end

  def self.down
    drop_table :years
  end
end
