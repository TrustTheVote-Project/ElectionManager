class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.string :display_name
      t.text :question
      t.integer :district_id
      t.integer :election_id

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end
