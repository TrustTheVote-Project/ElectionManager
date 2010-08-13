class AddIdentToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :ident, :string
    
    all_qstn = Question.find(:all)
    all_qstn.each do |qstn|
      qstn.ident = "qstn-#{qstn.id}"
      qstn.save!
    end
  end

  def self.down
    remove_column :questions, :ident
  end
end
