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