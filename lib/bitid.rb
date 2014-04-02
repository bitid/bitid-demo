class Bitid

  SCHEME = 'bitid'
  ACTION_LOGIN = 'login'
  PARAM_NONCE = 'x'
  PARAM_CALLBACK = 'c'

  def initialize hash={}
    @nonce = hash[:nonce]
    @callback = hash[:callback]
    @address = hash[:address]
    @signature = hash[:signature]
    begin
      if hash[:uri].blank?
        build_uri
      else
        @uri = URI(hash[:uri])
      end
    rescue
    end
  end

  def uri
    @uri
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
      return false if !params[PARAM_CALLBACK][0].eql?(@callback) || @callback.blank?
      true
    end
    rescue
      false
  end

  def signature_valid?
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