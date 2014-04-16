class Bitid

  SCHEME = 'bitid'
  PARAM_NONCE = 'x'
  SIGNATURE_HEADER = "Bitcoin Signed Message:\n"

  attr_accessor :nonce, :callback, :signature, :uri

  def initialize hash={}
    @nonce = hash[:nonce]
    @callback = URI(hash[:callback])
    @signature = hash[:signature]
    @address = hash[:address]
    if hash[:uri].blank?
      build_uri
    else
      @uri = URI(hash[:uri])
    end
    rescue
  end

  def uri_valid?
    if @uri.blank?
      false
    elsif @uri.scheme != SCHEME
      false
    elsif @uri.host != @callback.host
      false
    elsif @uri.path != @callback.path
      false      
    else
      params = CGI::parse(@uri.query)
      return false unless params[PARAM_NONCE][0].present?
      true
    end
    rescue
      false
  end

  def signature_valid?
    BitcoinCigs.verify_message(@address, @signature, message)
  end

  def qrcode
    "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=" + CGI::escape(message)
  end

  def nonce
    CGI::parse(@uri.query)[PARAM_NONCE][0]
  end

  def message
    SIGNATURE_HEADER + @uri.to_s
  end

  def callback
    @callback
  end

  private

  def build_uri
    @uri = @callback
    @uri.scheme = SCHEME
    @uri.query = URI.encode_www_form({PARAM_NONCE => @nonce.uuid})
  end
end
