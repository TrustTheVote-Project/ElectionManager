class CreateBallotStyles < ActiveRecord::Migration
  def self.up
    create_table :ballot_styles do |t|
      t.string :display_name

      t.timestamps
    end
  end

  def self.down
    drop_table :ballot_styles
  end
end
