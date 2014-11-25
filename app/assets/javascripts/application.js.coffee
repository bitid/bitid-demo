#= require jquery
#= require jquery_ujs
#= require bootstrap
#= require ./btchip
#= require btchip_auth

LW=
  checkCardDelay: 500

  init: ->
    this.hidePinPad()

    $("#lw").on 'submit', (e) =>
      pin = $("#pinpad").val()
      console.info("Pin submitted")
      this.onPinSubmitted(pin)
      e.preventDefault()
      return false

  checkCardHere: ->
    BtchipAuth.onHW1PlugIn (card) =>
      console.info("Card plugged !")
      this.showPinpad()
      @card = card
      setTimeout (=>
        BtchipAuth.onHW1PlugOut =>
          console.info("Card unplugged !")
          this.hidePinPad()
          @card = null
          setTimeout (=> this.checkCardHere()), @checkCardDelay
      ), @checkCardDelay

  showPinpad: ->
    $("#pinpad-div").show();

  hidePinPad: ->
    $("#pinpad-div").hide();
    $("#pinpad").val('')

  onPinSubmitted: (pin) ->
    return alert("Btchip card is lost !\nReplug it and retry.") if ! @card?
    BtchipAuth.getChallenge_async().then(
      (challenge) =>
        console.log("pin + challenge OK :", challenge)
        return BtchipAuth.getMessageSignature_async(@card, pin, challenge).then(
          (sig) =>
            console.log("SIG =", sig)
            $("#signed_challenge").val(sig)
            $("#lw").off('submit').submit()
          , (reason) =>
            console.error("Fail to getMessageSignature_async :", reason)
            alert(reason)
        )
      , (reason) =>
        alert("Fail to get challenge from server and sign it :", reason)
    ).done()

window.LW = LW