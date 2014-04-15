class AddSecretToNonce < ActiveRecord::Migration
  def change
    add_column :nonces, :secret, :string
  end
end
