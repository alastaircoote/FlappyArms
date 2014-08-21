define [
    "client/player"
], (Player) ->

    fakePlayers = []

    class FakePlayer
        constructor: (@idx) ->
            @player = new Player()
            @player.connect FakePlayer.connectId
            $(window).on "keydown", (e) =>
                keyCode = @idx + 49
                if e.keyCode == keyCode
                    @player.sendFlap()



        @hookKbEvents: () =>
            
            $(window).on "keydown", (e) =>
                keyCode = @index + 49
                if e.keyCode == 192 
                    p = new FakePlayer(fakePlayers.length)
                    fakePlayers.push p
                    
                ###
                if e.keyCode != keyCode then return
                
                if e.shiftKey
                    return @disconnect()
                else if @index == null
                    return   
                else
                    return @trigger "flap", @
                console.log e
                ###