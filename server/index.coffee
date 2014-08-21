http = require "http"
sockjs = require "sockjs"
SockJSEvented = require "./sockjs-evented"


#io = require('socket.io').listen(5000)
{PeerServer} = require('peer')
Host = require "./hostclient"
peer = new PeerServer {port: 5011, path: "/"}
echo = sockjs.createServer()

server = http.createServer()
echo.installHandlers(server, {prefix:'/flappyarms'})

server.listen(5010, '0.0.0.0')

peer.on "connection", ->
    #console.log "peer connected"

peer.on "disconnection", ->
    console.log "peer disconnected"


echo.on 'connection', (socket) ->

    sock = new SockJSEvented(socket)
    sock.on "is-host", (args) ->
        console.log "Creating new host"
        hc = new Host(sock)
    sock.on "is-client", (args) ->
        console.log "Searching for #{args.code}"
        hc = Host.get(args.code)
        if !hc
            return sock.send 'no-host'

        hc.attachClient sock

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