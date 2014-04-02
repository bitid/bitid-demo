class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :btc
      t.integer :signin_count, default: 0

      t.timestamps
    end
  end
end
