class HomeController < ApplicationController

  def login
    @nonce = Nonce.create
    @bitid = Bitid.new({nonce:@nonce, callback:callback_index_url})
  end
end