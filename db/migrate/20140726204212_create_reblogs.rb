class CreateReblogs < ActiveRecord::Migration
  def change
    create_table :reblogs do |t|
      t.string :tumblr_id
      t.string :reblogged_by

      t.timestamps
    end
  end
end
