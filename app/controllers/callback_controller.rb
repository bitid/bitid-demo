class CallbackController < ApplicationController

  def create
    @address = params[:address]
    bitid = Bitid.new(uri:params[:uri], signature:params[:signature], address:@address, callback:callback_index_url)

    if !bitid.uri_valid?
      render json: { message: "BitID URI is invalid or not legal"}, status: :unauthorized
    elsif !bitid.signature_valid?
      render json: { message: "Signature is incorrect"}, status: :unauthorized
    else
      @nonce = Nonce.find_by_uuid(bitid.nonce)
      if @nonce.nil?
        render json: { message: "NONCE is illegal"}, status: :unauthorized
      elsif @nonce.expired?
        render json: { message: "NONCE has expired"}, status: :unauthorized
      else
        render json: { address: @address, nonce: @nonce.uuid, count:@user.count }
      end
    end
  end
end