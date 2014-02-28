define ["jquery","flap","servers"], ($, flap, servers) ->
    class Client
        constructor: ->
            $("body").addClass("client")
            @tb = $("<input type='number'/>")
            @button = $("<button>Enter</button>")
            #@button.on "touchstart", (e) ->
            #    console.log "ts"
            #    e.stopPropagation()
            @button.on "click", @connect
            @tb.on "keydown", @keydowned

            $("body").append @tb, @button
            console.log "sdfsd"
            flap()

        connect: (e) =>
            console.log "stffff"
            e.preventDefault()
            val = "11"
            key = parseInt val.substr(1), 10
            console.log servers[key-1]
            @socket = io.connect servers[key-1]
            @socket.on "connect", =>
                console.log "connected"
                @socket.emit "attach-to-id", {code: val}
            @socket.on "got-host", @gotHost


        keydowned: (e) =>
            console.log e
            e.preventDefault()
            e.stopPropagation()

        gotHost: =>
            console.log "got host"
            $("body").on "flap", =>
                console.log "touched"
                @socket.emit "send", {ev: "toucherated", time:Date.now()}

