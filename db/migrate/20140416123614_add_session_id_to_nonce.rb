class AddSessionIdToNonce < ActiveRecord::Migration
  def change
    add_column :nonces, :session_id, :string
  end
end
