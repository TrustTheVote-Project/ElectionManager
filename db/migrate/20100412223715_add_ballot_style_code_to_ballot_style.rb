class AddBallotStyleCodeToBallotStyle < ActiveRecord::Migration
  def self.up
    add_column :ballot_styles, :ballot_style_code, :string
  end

  def self.down
    remove_column :ballot_styles, :ballot_style_code
  end
end
