class AddIdentToCandidate < ActiveRecord::Migration
  def self.up
    add_column :candidates, :ident, :string
    all_cand = Candidate.find(:all)
    all_cand.each do |cand|
      cand.ident = "cand-#{cand.id}"
      cand.save!
    end
  end

  def self.down
    remove_column :candidates, :ident
  end
end
