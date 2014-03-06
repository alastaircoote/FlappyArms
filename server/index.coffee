io = require('socket.io').listen(5000)

savedSockets = []

removeSocket = (entry) ->
    found = savedSockets.filter((s) => s.socket.id == this.id)[0]
    if found
        savedSockets.splice savedSockets.indexOf(found), 1
    console.log "disconnected, now #{savedSockets.length} clients..."
io.set( 'origins', 'http://experimenting.alastair.is:80' )

io.sockets.on 'connection', (socket) ->
    
    savedSockets.push {
        socket: socket
    }

    socket.on "get-id", () ->
        entry = savedSockets.filter((s) => s.socket.id == this.id)[0]
        code = Math.round(Math.random() * 1000)
        while savedSockets.filter((s) -> s.hostCode == code).length > 0
            # Get new ID
            code = Math.round(Math.random() * 1000)

        entry.code = code
        socket.emit "send-id", code

    socket.on "attach-to-id", (args) ->
        console.log "Looking for host" + parseInt(args.code.substr(1)) + " in "
        console.log savedSockets
        host = savedSockets.filter((s) => s.code == parseInt(args.code.substr(1)))[0]
        
        if !host
            return this.emit "receive", {ev:"no-host"}

        if host.client
            return this.emit "receive", {ev:"already-used"}
        this.host = host.socket
        host.client = this
        host.socket.emit "got-client"
        this.emit "got-host"

        socket.on "disconnect", (data) ->
            if !socket.host then return
            socket.host.client = null
            socket.host.emit "receive", {ev: "client-disconnected"}

        host.socket.on "disconnect", (data) ->
            socket.host = null
            socket.emit "receive", {ev:"host-disconnected"}

        socket.on "send", (data) ->
            #entry = savedSockets.filter((s) => s.client?.id == this.id)[0]
            socket.host.emit "receive", data

        this.host.on "send", (data) ->
            socket.emit "receive", data

    socket.on "disconnect", removeSocket