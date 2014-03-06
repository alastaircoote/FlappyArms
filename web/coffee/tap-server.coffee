define ["servers","socket","game/main","host-comm"], (servers, io, Birdie, HostCommLayer) ->
    class Server
        constructor: ->
            comm = new HostCommLayer()
            comm.connect()

            comm.on "id-received", @receiveId
            comm.on "receive", @receive

            $("#gamecontainer, #instruction-box").css "display","block"
            Birdie()
            @flapsSoFar = 0

            $("body").on "gameStarted", ->
                $("#bigscore").show()
                $("#instruction-box").hide()
                $("#howtoplay, #intro, h1").hide()

            $("body").on "gameover", @gameover

        gotClient: =>
            if $("#gameover").css("display") == "block" then return
            $("#intro").hide()
            $("#howtoplay, #signals").show()

        receiveId: (data) =>
            @socketId = data
            $("#numbers").html data

        receive: (data) =>
            console.log data
            if data.ev == "toucherated" then @flap(data)
            if data.ev == "client-attached" then @gotClient()

            if data.ev == "client-disconnected"
                console.log "disconnect"
                return window.location.reload()
                $("#instruction-box").show()
                $("#intro").show()
                $("#howtoplay, #signals").hide()


        flap: (data) =>
            @flapsSoFar++

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

            console.log arguments
###
comm.server = () ->

    div = $("<div/>")
    #$("body").append(div)

    socket = io.connect('http://actuallyflaptho.alastair.is:80');
    socket.emit "get-id"
    socket.on "send-id", (val) ->
        div.html "Go on your phone and enter 1" + val

    socket.on "got-client", ->
        console.log "got client"

    gamestarted = false
    socket.on "receive", (data) ->
        if data.ev == "toucherated"
            console.log "flapped"
            #console.log Date.now() - data.time
            #console.log "touched"
            game = window.game

            if game.isGameOver or !gamestarted
                game.gameOver false
                if !gamestarted then game.start()
                gamestarted = true
                return

            game.keyPressed["space"] = {}
            game.keyPressed["space"]["keydown"] = true
            game.keyPressed["space"]["keyup"] = false

            setTimeout ->
                game.keyPressed["space"] = {}
                game.keyPressed["space"]["keydown"] = false
                game.keyPressed["space"]["keyup"] = true
            ,20
###