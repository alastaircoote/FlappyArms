comm.client = () ->
    $("body").addClass("client")
    tb = $("<input type='number'/>")
    button = $("<button>Enter</button>")
    socket = io.connect('http://actuallyflaptho.alastair.is:80');

    tb.on "keydown", (e) ->
        console.log e
        e.preventDefault()
        e.stopPropagation()

    $("body").append tb, button

    socket.on "attached", ->
        console.log "attached"

    button.on "touchstart", (e) ->
        e.stopPropagation()
    button.on "click", (e) ->
        console.log "hi"
        e.preventDefault()
        socket.emit "attach-to-id", {code: "11"}



    socket.on "got-host", (data) ->

        $("body").on "flap", ->
            console.log "touched"
            socket.emit "send", {ev: "toucherated", time:Date.now()}

