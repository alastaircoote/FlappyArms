comm.server = () ->

    div = $("<div/>")
    $("body").append(div)

    socket = io.connect('http://10.0.1.9:5000');
    socket.emit "get-id"
    socket.on "send-id", (val) ->
        div.html "Go on your phone and enter 1" + val

    socket.on "got-client", ->
        console.log "got client"

    socket.on "touched", ->
        console.log "touched"