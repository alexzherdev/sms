class CreateTerms < ActiveRecord::Migration
  def self.up
    create_table :terms do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.belongs_to :year
      t.timestamps
    end
  end

  def self.down
    drop_table :terms
  end
end
