define ["servers","socket","game/main"], (servers, io, Birdie) ->
    class Server
        constructor: ->
            @key = Math.floor(Math.random() * servers.length)
            @socket = io.connect(servers[@key])
            @socket.on "send-id", @receiveId
            @socket.on "receive", @receive
            @socket.on "got-client", @gotClient
            @socket.emit "get-id"
            $("#gamecontainer, #instruction-box").css "display","block"
            Birdie()
            @flapsSoFar = 0

        gotClient: =>
            $("#intro").hide()
            $("#howtoplay").show()

        receiveId: (data) =>
            @socketId = data
            $("#numbers").html String(@key+1) + data

        receive: (data) =>
            if data.ev == "toucherated" then @flap(data)


        flap: (data) =>
            console.log "flap!"
            
            @flapsSoFar++

            if @flapsSoFar == 1
                $("#signal1").addClass("active")
            else if @flapsSoFar == 2
                $("#signal2").addClass("active")
            else if @flapsSoFar == 3
                $("#signal3").addClass("active")
            else
                if @flapsSoFar == 4
                    $("#instruction-box").css "opacity", 0
                $("body").trigger "flap"
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