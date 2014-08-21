define [
    "libs/peer"
    "libs/sockjs.min"
    "libs/microevent"
    "servers"
    "logger"
    "sockjs-microevented"
], (Peer, SockJS, MicroEvent, Servers, Logger, SockJSEvented) ->
    class ServerComms extends MicroEvent
        constructor: ->
            @targetSockServer = Servers.socketio[0]
            @webrtcClients = {}

        connect: =>
            @socket = new SockJSEvented new SockJS @targetSockServer
            console.log @targetSockServer
            @socket.on 'connect', =>
                Logger.info "Connected to socket.io server"
                @socket.emit 'is-host'

            @socket.on 'receive-id', @setId

            @socket.on 'event', (ev,data) =>
                if ev.indexOf(':') > -1
                    @trigger ev, data

        setId: ({id}) =>
            @id = id
            @trigger 'got-id', @id
            @peerClient = new Peer id, {host: Servers.webrtc[0].host, port:Servers.webrtc[0].port, debug:3}

            @peerClient.on 'connection', @rtcActive

        rtcActive: (rtc) =>
            

            @webrtcClients[rtc.metadata.clientId] = rtc

            rtc.on 'data', (data) =>
                @trigger rtc.metadata.clientId + ':' + data.ev, data.data

            rtc.on 'close', -> console.log 'did disconnect?'

        send: (id, ev, data) =>

            rc = @webrtcClients[id]
            
            if rc and rc.open
                rc.send {ev: ev, data: data}
            else
                console.log 'send via socket'
                @socket.emit id + ':' + ev, data

        onId: (id, ev, func) ->
            @on id + ':' + ev, func
