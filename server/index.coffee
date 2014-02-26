io = require('socket.io').listen(5000)

savedSockets = []

removeSocket = (entry) ->
    found = savedSockets.filter((s) => s.socket.id == this.id)[0]
    if found
        savedSockets.splice savedSockets.indexOf(found), 1
    console.log "disconnected, now #{savedSockets.length} clients..."
io.set( 'origins', '*:*' )

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
        host = savedSockets.filter((s) => s.code == parseInt(args.code.substr(1)))[0]
        this.host = host.socket
        host.client = this
        host.socket.emit "got-client"
        this.emit "got-host"

        socket.on "toucherated", ->
            #entry = savedSockets.filter((s) => s.client?.id == this.id)[0]
            socket.host.emit "touched"

    socket.on "disconnect", removeSocket