class HomeController < ApplicationController

  def login
    @nonce = Nonce.create
    @bitid = Bitid.new({nonce:@nonce, callback:callback_index_url})
  end

  def auth
    nonce = Nonce.find_by_uuid_and_secret(params[:nonce], params[:secret])
    if nonce && nonce.user.present?
      sign_in nonce.user
      nonce.destroy
      render json: { auth: 1 }
    else
      render json: { auth: 0 }
    end
  end
end