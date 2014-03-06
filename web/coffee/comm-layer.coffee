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
            @on "receive", @logHeartbeat
        connectSocketIO: (idx) =>
            @serverIndex = idx
            targetServer = servers.socketio[idx]
            if !targetServer
                return @trigger "badserver"
            Logger.info "Mapped socket.io server index #{idx} to #{targetServer}"

            @socket = io.connect targetServer
            @socket.on "receive",(data) =>  @receiveSocket(data)
            @socket.on "disconnect", () => @socketDisconnected()
            @socket.on "connect", =>
                Logger.info "Connected to socket.io server"
                @trigger "socketio-connected"
                @connectWebRTC()

        connectWebRTC: (id) =>
            if !@SupportsWebRTC
                @trigger "connections-complete"
                return Logger.info "Browser does not support WebRTC data :("

            @peer = new Peer {host: servers.webrtc[@serverIndex], port: 5001, path: "/"}
            @peer.on "connection", (peerConnection) => @setRTCConnection(peerConnection)
            @peer.on "error", () =>
                # For whatever reason, connection failed.
                Logger.info "Unable to reach peering server. Falling back to socket.io..."
                @trigger "connections-complete"

            @peer.on "close", () => Logger.info "Disconnected from peering server"
            Logger.info "Browser supports WebRTC data, connecting to server..."
            @peer.on "open", (id) =>
                Logger.info "Received WebRTC PeerId #{id}."
                @trigger "webrtc-connected", id
                @trigger "connections-complete"
                $("#spanConnMethod").html "WebRTC"
            

        receiveSocket: (data) =>
            if data.ev == "host-attached" && data.peerId && @SupportsWebRTC
                # Let's try connecting via WebRTC
                Logger.info "Attempting to connect via WebRTC..."
                peerConnection = @peer.connect data.peerId
                peerConnection.on "open", =>
                    @setRTCConnection(peerConnection)
                    # Now we send the original event we held back.
                    @trigger "receive", data
                return
            @trigger "receive", data

        setRTCConnection: (@peerConnection) =>
            Logger.info "Successfully established WebRTC connection"
            @peerConnection.on "data", (data) => @trigger "receive", data
            @peerConnection.on "close", () => @webRtcDisconnected()
            @peerConnection.on "error", (e) => console.log "error", e
            @heartbeatInterval = setInterval () =>
                @sendHeartbeat()
            , 1000
            @useWebRTC = true


            # We can now close the connection to the peering server
            #@peer.disconnect()
            # Close our the socket.io connection
            @socket.disconnect()

        sendHeartbeat: =>
            if @lastHeartbeat && @lastHeartbeat < Date.now() - 3000
                @lastHeartbeat = null
                @peerConnection.close()
                @peer.destroy()
                clearInterval @heartbeatInterval
            @peerConnection.send {ev:"heartbeat", time: Date.now()}

        logHeartbeat: (data) =>
            if data.ev == "heartbeat"
                @lastHeartbeat = data.time
            if data.time # WebSockets flap events also have a ping
                @trigger "ping", (Date.now() - data.time)
                #Logger.info "Closing connection to peer server..."
                #if !@peer.disconnected then @peer.destroy()


        send: (data) =>
            if @useWebRTC
                @peerConnection.send data
            else
                @socket.emit "send", data


        webRtcDisconnected: () =>
            Logger.info "WebRTC connection closed."
            @trigger "disconnected"
        socketDisconnected: () =>
            Logger.info "Closed socket.io connection."

             # Hack as detailed here: https://github.com/LearnBoost/socket.io-client/issues/251#issuecomment-2589557

            io.j = []
            io.sockets = []

            if !@useWebRTC then @trigger "disconnected"
           

        disconnect: () =>
            if @socket then @socket.disconnect()

