comm.client = () ->
    tb = $("<input type='number'/>")
    button = $("<button>Enter</button>")
    socket = io.connect('http://10.0.1.9:5000');

    $("body").append tb, button

    socket.on "attached", ->
        console.log "attached"


    button.on "click", (e) ->
        console.log "hi"
        e.preventDefault()
        socket.emit "attach-to-id", {code: tb.val()}


    socket.on "got-host", ->
        console.log "got host"
        $("body").on "click", ->
            console.log "touched"
            socket.emit "toucherated"

