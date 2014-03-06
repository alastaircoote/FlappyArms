define ["comm-layer","servers","logger"], (CommLayer,servers, Logger) ->
    class HostCommLayer extends CommLayer
        constructor: ->
            @on "socketio-connected", => @socket.emit "is-host"
            @on "webrtc-connected", @webRTCConnected
            @on "receive", @receive
            super()

        connect: () =>
            @serverIndex = Math.floor(Math.random() * servers.socketio.length)
            Logger.info "Chose to connect to server ##{@serverIndex}"
            @connectSocketIO @serverIndex

        receive: (data) =>
            if data.ev == "receive-id"
                Logger.info "Received socket.io ID #{data.id} from server ##{@serverIndex}"
                @trigger "id-received", String(@serverIndex+1) + data.id


        webRTCConnected: (id) =>
            Logger.info "Sending WebRTC peer ID #{id} to socket.io server..."
            @socket.emit "attach-peerid", id