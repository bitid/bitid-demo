
BtchipAuth =
  walletPath: "0'/0/0xb11e"
  checkCardHereDelay: 1000
  
  cardFactory: ->
    @cardFact ||= new ChromeapiPlugupCardTerminalFactory(0x2b7c)

  signOut: ->
    $.ajax(
      type: "DELETE"
      url: "/users/sign_out"
    ).done ->
      window.location.assign("/users/sign_in")

  signOutOnUnplug: ->
    this.onHW1PlugOut(=> this.signOut())

  signOutOnPlug: ->
    this.onHW1PlugIn(=> this.signOut())

  onHW1PlugIn: (cb) ->
    console.debug("Check if Ledger Wallet is plugged...")
    this.getDongleList_async().then(
      (dongle_list) =>
        if dongle_list.length == 0
          console.debug("No Ledger Wallet plugged.")
          setTimeout =>
            this.onHW1PlugIn(cb)
          , @checkCardHereDelay
        else
          console.debug("New Ledger Wallet plugged !")
          this.dongleToCard_async(dongle_list[0]).then (card) =>
            cb(card)
      , (e) =>
        console.warn("Fail to check if Ledger Wallet is always plugged : #{e}. Try again.")
        setTimeout =>
          this.onHW1PlugIn(cb)
        , @checkCardHereDelay
    ).done()

  onHW1PlugOut: (cb) ->
    console.debug("Check if Ledger Wallet is still plugged...")
    this.getDongleList_async().then(
      (dongle_list) =>
        if dongle_list.length != 0
          console.debug("Ledger Wallet still plugged.")
          setTimeout =>
            this.onHW1PlugOut(cb)
          , @checkCardHereDelay
        else
          console.debug("Ledger Wallet unplugged !")
          cb()
      , (e) =>
        console.warn("Fail to check if Ledger Wallet is always plugged : #{e}. Try again.")
        setTimeout =>
          this.onHW1PlugOut(cb)
        , @checkCardHereDelay
    ).done()

  # Return a promise with callback(sig)
  getMessageSignature_async: (card, pin, message) ->
    d = Q.defer()
    message = new ByteString(message, ASCII)
    pin = new ByteString(pin, ASCII)

    console.log("before verifyPin_async", card)
    card.verifyPin_async(pin).then(
      (result_vpin) =>
        console.log('PIN verified')
        card.signMessagePrepare_async(@walletPath, message).then(
          (result_prepare) =>
            console.log("Challenge prepared")
            card.signMessageSign_async(pin).then (result_sign) =>
              signature = result_sign
              console.log("Challenge signed")
              conv_sig = this.convertMessageSignature(signature)
              console.log("Signature Base64 encoded")
              d.resolve(conv_sig)
              return conv_sig
          , (e) =>
            console.error("Fail to sign challenge : #{e}")
            d.reject("Fail to sign challenge : #{e}")
        )
      , (e) =>
        console.error("Fail to verifyPin_async :", e)
        if m = e.match(/63c(\d)/)
          remainingPinAttempts = m[1]
          d.reject("Wrong PIN, #{m[1]} tentatives remaining.\n\n--> UNPLUG the Ledger Wallet <--")
        else
          d.reject("Unknow error : #{e}.\n\n--> UNPLUG the Ledger Wallet <--")
    )
    return d.promise

  printWalletPublicKey: ->
    this.getCard_async().then (card) =>
      throw "No card available" if ! card?
      card.getWalletPublicKey_async(@walletPath).then (wallet_pubkey) ->
        console.log("bitcoinAddress=", wallet_pubkey.bitcoinAddress.value)
        console.log("publicKey=", wallet_pubkey.publicKey.value)

  getRemainingPinAttempts_async: ->
    this.getCard_async().then (card) =>
      throw "No card available" if ! card?
      return card.getRemainingPinAttempts_async()

  # Return a promise with callback(btchip_card)
  # If no card is available, return null.
  getCard_async: (refresh=false) ->
    if ! refresh && @card?
      d = Q.defer()
      d.resolve(@card)
      return d.promise
    else
      @card = null
      return this.getDongleList_async().then(
        (dongle_list) =>
          return @card if dongle_list.length == 0
          this.dongleToCard_async(dongle_list[0])
        , (reason) ->
          console.warn("Fail to get dongles list", reason)
          throw reason
      )

##################
# Private Methods
##################

  getDongleList_async: ->
    d = Q.defer()
    p = this.cardFactory().list_async()
    p.then(
      (result) ->
        d.resolve(result)
      , (reason) ->
        d.reject(reason)
    )
    setTimeout( =>
      d.reject("No response") if p.isPending()
    , 200)
    return d.promise

  # Return a promise with callback(card)
  dongleToCard_async: (dongle) ->
    return this.cardFactory().getCardTerminal(dongle).getCard_async().then (card) -> new BTChip(card)

  diagnostic: (pin) ->
    niceTry = (f) ->
      try
        r = f()
        if r instanceof Promise then r.fail((e) -> console.error(e)) else r
      catch e
        console.error(e, e.stack)

    niceTry =>
      # cardFact = new ChromeapiPlugupCardTerminalFactory()
      cardFact = this.cardFactory()
      console.log("Going to get dongle list...")
      cardFact.list_async().then (dongles_list) =>
        niceTry =>
          console.log("=> Retrieve a list of", dongles_list.length, "dongles.", dongles_list)
          return if dongles_list.length == 0
          dongle = dongles_list[0]
          terminal = @cardFact.getCardTerminal(dongle)
          console.log("Going to convert terminal to card...")
          terminal.getCard_async().then (card) =>
            niceTry =>
              console.log("=> Terminal converted")
              btchipCard = new BTChip(card)
              console.log("Going to getRemainingPinAttempts...")
              btchipCard.getRemainingPinAttempts_async().then (nb) =>
                niceTry =>
                  console.log("=>", nb, "attempts remaining !")
                  return unless pin
                  console.log("Going to verifyPin...")
                  btchipCard.verifyPin_async(pin).then (r) =>
                    console.log("=> Verified !", r)

  getChallenge_async: ->
    d = Q.defer()
    @challenge ||= $("meta[name=csrf-token]").attr("content")
    d.resolve(@challenge)
    # $.get("http://localhost:3000/login.json").done (data) ->
    #   console.log("Challenge: ", data.btchip_auth)
    #   d.resolve(data.btchip_auth)
    # .fail (e) ->
    #   console.log("Fail GET askChallenge", e)
    #   d.reject(e)
    return d.promise

  convertMessageSignature: (signature) ->
    splitSignature = this.splitAsn1Signature(signature.signature)
    sig = new ByteString(Convert.toHexByte(signature.parity + 27 + 4), HEX).concat(splitSignature[0]).concat(splitSignature[1])
    return this.convertBase64(sig)

  splitAsn1Signature: (asn1Signature) ->
    throw "Invalid signature format" if (asn1Signature.byteAt(0) != 0x30) || (asn1Signature.byteAt(2) != 0x02)
    rLength = asn1Signature.byteAt(3)
    throw "Invalid signature format" if asn1Signature.byteAt(4 + rLength) != 0x02
    r = asn1Signature.bytes(4, rLength)
    s = asn1Signature.bytes(4 + rLength + 2, asn1Signature.byteAt(4 + rLength + 1))
    r = r.bytes(1) if r.length == 33
    s = s.bytes(1) if s.length == 33
    throw "Invalid signature format" if (r.length != 32) || (s.length != 32)
    return [r, s]

  convertBase64: (data) ->
    codes = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    output = ""
    leven = 3 * (Math.floor(data.length / 3))
    offset = 0
    for i in [0...leven] by 3
      output += codes.charAt((data.byteAt(offset) >> 2) & 0x3f)
      output += codes.charAt((((data.byteAt(offset) & 3) << 4) + (data.byteAt(offset + 1) >> 4)) & 0x3f)
      output += codes.charAt((((data.byteAt(offset + 1) & 0x0f) << 2) + (data.byteAt(offset + 2) >> 6)) & 0x3f)
      output += codes.charAt(data.byteAt(offset + 2) & 0x3f)
      offset += 3
    if i < data.length
      a = data.byteAt(offset)
      b = if (i + 1) < data.length then data.byteAt(offset + 1) else 0
      output += codes.charAt((a >> 2) & 0x3f)
      output += codes.charAt((((a & 3) << 4) + (b >> 4)) & 0x3f)
      output += if (i + 1) < data.length then codes.charAt((((b & 0x0f) << 2)) & 0x3f) else '='
      output += '='
    return output

window.BtchipAuth = BtchipAuth
