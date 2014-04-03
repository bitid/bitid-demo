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
    @address = hash[:address]
    begin
      if hash[:uri].blank?
        build_uri
      else
        @uri = URI(hash[:uri])
      end
    rescue
    end    
  end

  def uri_valid?
    if @uri.blank?
      false
    elsif @uri.scheme != SCHEME
      false
    elsif @uri.host != ACTION_LOGIN
      false
    else
      params = CGI::parse(@uri.query)
      return false unless params[PARAM_NONCE][0].present? && params[PARAM_CALLBACK][0].present?
      return false if @callback.blank? || !@callback.eql?(Base64.decode64(params[PARAM_CALLBACK][0]))
      true
    end
    rescue
      false
  end

  def signature_valid?
    BitcoinCigs.verify_message(@address, @signature, @uri.to_s)
  end

  def qrcode
    "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=" + CGI::escape(@uri.to_s)
  end

  def nonce
    CGI::parse(@uri.query)[PARAM_NONCE][0]
  end

  private

  def build_uri
    params = {}
    params[PARAM_NONCE] = @nonce.uuid
    params[PARAM_CALLBACK] = Base64.strict_encode64(@callback)
    @uri = URI(SCHEME + '://' + ACTION_LOGIN + '?' + URI.encode_www_form(params))
  end    
end
