io = require('socket.io').listen(5000)
{PeerServer} = require('peer')
HostClient = require "./hostclient"
peer = new PeerServer {port: 5001, path: "/"}

peer.on "connection", ->
    console.log "peer connected"

peer.on "disconnection", ->
    console.log "peer disconnected"

io.set( 'origins', '*:*' )

io.sockets.on 'connection', (socket) ->

    socket.on "is-host", () ->

        hc = new HostClient(socket)

        ###
        entry = savedSockets.filter((s) => s.socket.id == this.id)[0]
        code = Math.round(Math.random() * 1000)
        while savedSockets.filter((s) -> s.hostCode == code).length > 0
            # Get new ID
            code = Math.round(Math.random() * 1000)

        entry.code = code
        socket.emit "send-id", code
        ###
    socket.on "is-client", (args) ->
        console.log "Searching for #{args.code}"
        hc = HostClient.get(args.code)
        if !hc
            return socket.emit "receive", {ev:"no-host"}
        else if hc.client
            return socket.emit "receive", {ev:"already-used"}

        hc.attachClient socket

        ###
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
        ###