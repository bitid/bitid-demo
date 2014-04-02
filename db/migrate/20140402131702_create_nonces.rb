class CreateNonces < ActiveRecord::Migration
  def change
    create_table :nonces do |t|
      t.string :uuid

      t.timestamps
    end
  end
end
