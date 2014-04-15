class AddUserIdToNonce < ActiveRecord::Migration
  def change
    add_column :nonces, :user_id, :integer
  end
end
