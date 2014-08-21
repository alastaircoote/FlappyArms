define [
    "jquery"
    "server/player"
    "libs/microevent"
], ($, Player) ->
    class ConnectWindow extends MicroEvent
        constructor: (@server) ->
            @$el = $("#connect-box")
            @$playerBox = $("#connect-players")

            @playerIDs = []
            @playersReady = 0

            @server.comm.on "got-id", @setId
            @server.comm.on "client-connect", @clientConnected
            @server.comm.on "flap", @flap

            @server.players.forEach (p) =>
                p.on "got-socket", @setPlayer
                p.on "disconnect", @resetPlayer
                p.on "flap", @playerFlapped

            @readyPlayers = 0

        show: =>
            #@$el.show()
            @$playerBox.empty()
            @playerEls = @server.players.map (p, i) ->
                inner = $("<div class='inner waiting-connect'></div>")
                birdIcon = $("<div class='birdicon'/>")

                color = Player.getColorFromIndex(i)

                birdIcon.addClass color + "-bird"

                inner.append birdIcon, """
                    <div class='flapboxes'><div class='flap-1'/><div class='flap-2'/><div class='flap-3'/></div>
                    <p class='initial'>Waiting for Player #{i+1} to connect...</p>
                    <p class='flapthree'>Player #{i+1} connected. Flap 3 times!</p>
                    <p class='ready'>You're ready to go!</p>
                """
                return $("<div class='redbox playerbox player#{i+1} #{color}'></div>").append(inner)

            @$playerBox.append @playerEls


        setPlayer: (player) =>
            box = $('.inner', @playerEls[player.index])
            $(".birdicon",box).addClass "anim"
            box.removeClass("waiting-connect").addClass("waiting-flaps")
            #$(".inner",box).prepend "<div class='flapboxes'><div/><div/><div/></div>"

        resetPlayer: (player, idx) =>
            box = $(".inner", @playerEls[idx])
            if box.hasClass("flapped-2")
                @readyPlayers--
            box.attr("class","inner waiting-connect")
            $(".birdicon",box).removeClass "anim"
            

        hide: =>
            @$el.hide()

        setId: (id) =>
            $("#numbers").html id

        playerFlapped: (player) =>
            box = $('.inner',@playerEls[player.index])
            if box.hasClass "flapped-2"
                box.removeClass("waiting-flaps").addClass("ready-to-go")
                @readyPlayers++
                if @readyPlayers == @server.numOfPlayers
                    # a delay so everyone can see what's happening
                    setTimeout () =>
                        @ready()
                        
                    , 1000
            else if box.hasClass "flapped-1"
                box.addClass "flapped-2"
            else
                box.addClass "flapped-1"

        ready: =>
            @server.players.forEach (p) =>
                p.off "got-index", @setPlayer
                p.off "disconnect", @resetPlayer
                p.off "flap", @playerFlapped
            @trigger "ready"
            
        ###
        clientConnected: (clientId) =>
            box = $(@playerEls[@playerIDs.length])
            $(".birdicon",box).addClass "anim"
            $("p",box).html "Player #{@playerIDs.length+1} connected. Flap 3 times!"
            $(".inner",box).prepend "<div class='flapboxes'><div/><div/><div/></div>"
            @playerIDs.push clientId

        flap: (id) =>
            idx = @playerIDs.indexOf(id)
            if idx == -1 then return # WTF
            box = $(@playerEls[idx])
            inactiveBlocks = $(".flapboxes div:not(.active)",box)
            inactiveBlocks.first().addClass "active"
            if inactiveBlocks.length == 1
                # Then we've done all three
                $(".flapboxes",box).remove()
                $("p",box).html "You're ready to go!"
                @playersReady++
                if @playersReady == @playerIDs.length
                    @allPlayersReady()
        ###


