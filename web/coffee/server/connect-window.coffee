define ["jquery"], ($) ->
    class ConnectWindow
        constructor: (@server) ->
            @$el = $("#connect-box")
            @$playerBox = $("#connect-players")

            @server.on "id-received", @setId

            @playerIDs = []
            @playersReady = 0

        show: =>
            @$el.show()
            @$playerBox.empty()
            @playerEls = [1..@server.numOfPlayers].map (i) ->
                inner = $("<div class='inner'></div>")
                birdIcon = $("<div class='birdicon'/>")
                color = "orig"
                switch i
                    when 2 then color = "red"
                    when 3 then color = "blue"
                    when 4 then color = "green"

                birdIcon.addClass color + "-bird"

                inner.append birdIcon, "<p>Waiting for Player #{i} to connect...</p>"
                return $("<div class='redbox playerbox player#{i} #{color}'></div>").append(inner)

            @$playerBox.append @playerEls

            # DUMMY
            @clientConnected(1)
          

            @flap(1)
            @flap(1)
            @flap(1)

        hide: =>
            @$el.hide()

        setId: (id) =>
            $("#numbers").html id

            # Now it's guaranteed to be there
            @comm = @server.comm
            @comm.on "client-connect", @clientConnected
            @comm.on "flap", @flap

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

        allPlayersReady: =>






