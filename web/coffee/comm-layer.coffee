define [
    "libs/peer"
    "libs/socketio"
    "servers"
    "libs/microevent"
    "logger"
], (Peer, io, servers, MicroEvent, Logger) ->
    class CommLayer extends MicroEvent
        SupportsWebRTC: util.supports.data
        constructor: () ->

        connectSocketIO: (idx) =>
            @serverIndex = idx
            targetServer = servers.socketio[idx]
            if !targetServer
                alert "No"
            Logger.info "Mapped socket.io server index #{idx} to #{targetServer}"
            if !@socket
                @socket = io.connect targetServer
                @socket.on "receive",(data) =>  @receiveSocket(data)
                @socket.on "connect", =>
                    Logger.info "Connected to socket.io server"
                    @trigger "socketio-connected"
                    @connectWebRTC()
            else
                @trigger "socketio-connected"

        connectWebRTC: (id) =>
            if !@SupportsWebRTC
                return Logger.info "Browser does not support WebRTC data :("
            @peer = new Peer {host: servers.webrtc[@serverIndex], port: 5001, path: "/"}
            @peer.on "connection", @webRTCConnectionEstablished
            Logger.info "Browser supports WebRTC data, connecting to server..."
            @peer.on "open", (id) =>
                Logger.info "Received WebRTC PeerId #{id}."
                @trigger "webrtc-connected", id


        receiveSocket: (data) =>
            if data.ev == "host-attached" && @SupportsWebRTC
                # Let's try connecting via WebRTC
                Logger.info "Attempting to connect via WebRTC..."
                @peerConnection = @peer.connect data.peerId
                @peerConnection.on "open", ->
                    Logger.info "Successfully established WebRTC connection"
                    @peerConnection.on "receive", (data) => @trigger "receive", data
                    @useWebRTC = true
                return
            @trigger "receive", data

        send: (data) =>
            if @useWebRTC
                Logger.info "Sending via webRTC"
                @peerConnection.send "receive", data
            else
                @socket.emit "send", data

        webRTCConnectionEstablished: (@peerConnection) ->
            Logger.info "Successfully established WebRTC connection with client."
            @peerConnection.on "receive", (data) => @trigger "receive", data
            @useWebRTC = true

        disconnect: () =>
            Logger.info "Closing connections..."
            @socket.disconnect()
            @peer.destroy()
