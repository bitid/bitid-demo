class Users::SessionsController < Devise::SessionsController

  def create
    if params[:signed_challenge].present?
      sign = Base64.decode64 params[:signed_challenge]
      message = params[:authenticity_token]
      address = address_from_signature(message, sign)
      user = User.find_or_create_by_btc(address)
      sign_in user
      redirect_to user_path
    end
  end

  protected
    def address_from_signature(message, signature)
      hash = Bitcoin.bitcoin_signed_message_hash(message)
      pubkey = Bitcoin::OpenSSL_EC.recover_compact(hash, signature)
      Bitcoin.pubkey_to_address(pubkey) rescue nil
    end
end