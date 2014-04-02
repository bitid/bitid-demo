class Bitid

  SCHEME = 'bitid'
  ACTION_LOGIN = 'login'
  PARAM_NONCE = 'x'
  PARAM_CALLBACK = 'c'

  attr_accessor :nonce, :callback, :signature, :uri

  def initialize hash={}
    @nonce = hash[:nonce]
    @callback = hash[:callback]
    @signature = hash[:signature]
    begin
      if hash['uri'].blank?
        build_uri
      else
        @uri = URI(hash['uri'])
      end
    rescue
    end
  end

  def uri_valid?
    if @uri.blank?
      false
    elsif @url.scheme != SCHEME
      false
    elsif @url.host != ACTION_LOGIN
      false
    else
      params = CGI::parse(bitid.uri.query)
      return false unless params[PARAM_NONCE][0].present? && params[PARAM_CALLBACK][0].present?
      return false if params[PARAM_CALLBACK][0] != @callback || @callback.blank?
      true
    end
    rescue
      false
  end

  def signature_valid?
    address = BitcoinCigs.get_signature_address(@signature, @uri.to_s)
    return false if address == false
    BitcoinCigs.verify_message(address, @signature, @uri.to_s)
  end

  def qrcode
    "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=" + URI.encode(@uri.to_s)
  end

  private

  def build_uri
    params = {}
    params[PARAM_NONCE] = @nonce.uuid
    params[PARAM_CALLBACK] = @callback
    @uri = URI(SCHEME + '://' + ACTION_LOGIN + '?' + URI.encode_www_form(params))
  end    
end
