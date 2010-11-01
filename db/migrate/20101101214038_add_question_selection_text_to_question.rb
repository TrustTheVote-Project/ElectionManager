class AddQuestionSelectionTextToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :agree_label, :string, :default => 'Yes'
    add_column :questions, :disagree_label, :string, :default => 'No'
  end

  def self.down
    remove_column :questions, :disagree_lable
    remove_column :questions, :agree_label
  end
end
