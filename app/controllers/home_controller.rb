class HomeController < ApplicationController

  def login
    @nonce = Nonce.create(session_id:@session_id)
    @bitid = Bitid.new({nonce:@nonce.uuid, callback:callback_index_url})
  end

  def auth
    nonce = Nonce.find_by_session_id(@session_id)
    if nonce && nonce.user.present?
      sign_in nonce.user
      nonce.destroy
      render json: { auth: 1 }
    else
      render json: { auth: 0 }
    end
  end
end