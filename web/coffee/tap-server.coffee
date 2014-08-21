define [
    "jquery"
    "server/comms"
    "logger"
    "game-new/game"
    "server/connect-window"
    "libs/microevent"
    "server/intro-box"
    "server/player"
    "server/score-board"
    "server/fake-player"
    ], ($, Comms, Logger, GameCanvas, ConnectWindow, MicroEvent, IntroBox, Player, ScoreBoard, FakePlayer) ->
    class Server extends MicroEvent
        constructor: ->
            $('body').addClass 'server'
            #$("#gamecontainer, #instruction-box").css "display","block"

            @comm = new Comms()
            
            @createGame()

            $("window").on "resize", () =>
                @gc.setOptions({
                    width: $(window).width()
                    height: $(window).height()
                });

            


            @introBox = new IntroBox()
            @introBox.on "numPlayersChosen", @playersChosen
            @introBox.show()
            # TODO :remove
            @playersChosen(2)

            FakePlayer.hookKbEvents()
            @comm.on "got-id", (id) ->
                FakePlayer.connectId = id


        createGame: =>
            if @gc
                @oldGameCanvas = $(@gc.el)

            @gc = new GameCanvas({
                width: $(window).width()
                height: $(window).height()
            })

            @gc.on "scored", @gameScored
            @gc.on "gameover", @gameOver

            @gc.el.css
                position:"absolute"
                left: "0%"
                top:0
            if @oldGameCanvas
                $(@gc.el).insertBefore @oldGameCanvas
            else
                $('#server').append @gc.el

        playerAdded: ({clientId}) =>
            
            for player in @players
                if player.connected then continue

                player.attachSocket clientId
                return
            @comm.send clientId, 'server-full'


        playersChosen: (num) =>
            @numOfPlayers = num
            # The player instances, unordered
            @players = [0...num].map (i) =>
                p = new Player(@comm, i)
                p.on "connect", @playerConnected
                p.on "disconnect", @playerDisconnected
                return p
            @connectWindow = new ConnectWindow(@)
            
            @connectWindow.on "ready", @startGame
            @connectWindow.show({})
            @connect()

            $("body").attr "class", "server show-connect"

        getPlayerAt: (idx) =>
            for player in @players
                if player.index == idx then return player

            return null

        playerConnected: (player) =>
            for i in [0..@numOfPlayers]
                console.log "trying player at #{i}"
                if @getPlayerAt(i) then continue

                player.setIndex(i)
                break

        playerDisconnected: (player) =>


        gameScored: () =>
            for player in @players
                if player.bird.status != "alive" then continue
                player.score++

        gameOver: () =>
            for player in @players
                player.off @flap, @playerFlapped

            @connectWindow.show({showScores:true})
            $("body").attr "class", "server show-connect"
            @createGame()

        hideAll: =>
            # Sort of a catch all to disable and hide everything, no
            # matter where we are.
            @connectWindow.hide()
            $("#instruction-box").hide()
            $("body").off "keydown", @introKeypress


        connect: =>
            @comm.connect()
            @comm.socket.on 'client-attached', @playerAdded


        playerFlapped: (player) =>
            player.bird.flap()

        startGame: () =>
            @hideAll()

            @players.forEach (p) =>
                p.on "flap", @playerFlapped
                p.score = 0
                bird = @gc.addBird()
                p.bird = bird


            countdownEl = $("#countdown-box h4")
            countdownEl.html "3"
            $("body").attr 'class', "server show-countdown"
            if @oldGameCanvas then @oldGameCanvas.remove()
            c = 4
            doCountdown = () =>
                c--
                if c == 0
                    $("body").attr 'class', 'server play-game'

                    return @gc.start()

                countdownEl.html c
                setTimeout doCountdown, 1000

            doCountdown()

            #@gc.start()

        
        ###
        gotClient: =>
            if $("#gameover").css("display") == "block" then return
            $("#intro").hide()
            $("#howtoplay, #signals").show()
        
        receive: (data) =>
            if data.ev == "toucherated" then @flap(data)
            if data.ev == "client-attached" then @gotClient()

        flap: (data) =>
            @flapsSoFar++
            d = new Date()
            dFormat = d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds() + ":" + d.getMilliseconds()
            Logger.info "Received message at " + dFormat
            if @flapsSoFar == 1
                $("#signal1").addClass("active")
            else if @flapsSoFar == 2
                $("#signal2").addClass("active")
            else if @flapsSoFar == 3
                $("#signal3").addClass("active")
            else
                $("body").trigger "flap"

        
        gameover: (e, score) =>
            $("#bigscore").hide()
            $("#score").html score
            $("#gameover, #signals").show()
            $("#signals .signal.active").removeClass("active")
            $("#instruction-box").show()

            @flapsSoFar = 0

        disconnected: () =>
            $("#numbers").html ""
            @socketId = null
            $("#intro, #instruction-box, h1").show()
            $("#howtoplay, #signals, #gameover").hide()
            $("body").trigger "resetgame"
            @comm.connect()
        ###