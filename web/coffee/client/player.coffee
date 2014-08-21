define [
    "libs/peer"
    "libs/sockjs.min"
    "libs/microevent"
    "servers"
    "logger"
    "sockjs-microevented"
], (Peer, SockJS, MicroEvent, Servers, Logger, SockJSEvented) ->
    class Player extends MicroEvent
        constructor: ->
            Logger.info 'created new player'

        connect: (id) ->
            serverIndex = Number(id[0]) - 1
            targetSockServer = Servers.socketio[0]
            @socket = new SockJSEvented new SockJS targetSockServer
            @socket.on 'connect', =>
                @socket.emit 'is-client', {code: id}
            @socket.on 'host-attached', (data) =>
                @clientId = data.clientId
                if window.location.href.indexOf("disablewebrtc=1") == -1 and util.supports.data
                    @peerClient = new Peer {host: Servers.webrtc[0].host, port:Servers.webrtc[0].port}
                    
                    @dataConnection = @peerClient.connect id, {metadata: {clientId: data.clientId}}
                    @dataConnection.on 'close', =>
                        console.log 'closed'
                        @dataConnection = null

                    @dataConnection.on 'data', (data) =>
                        @trigger data.ev, data.data
                    
                    @peerClient.on 'error', (e) -> console.log e

                @trigger 'connected', data.clientId
                @connected = true
                @startPing()

            @socket.on 'disconnected', @disconnect
            @socket.on 'event', @receiveSocketEvent
            @on 'pong', @receivePong


        disconnect: =>
            @socket.emit 'disconnect'
            @socket.close()
            if @dataConnection
                @dataConnection.send {ev:'disconnect'}
                @dataConnection.close()

            @trigger 'disconnected'
            @connected = false
            

        receivePong: (time) =>
            open = @dataConnection?.open
            @send 'ping-result', {time: (Date.now() - time) / 2, rtc: open}
            #console.log 'ping time', (Date.now() - time) / 2, 'rtc is ' + open
            

        startPing: =>
            @send 'ping', Date.now()
            if @connected then setTimeout @startPing, 2000

        sendFlap: =>
            @send 'flap'


        send: (ev, data) =>
            if @dataConnection?.open
                @dataConnection.send {ev:ev, data:data}
            else
                @socket.emit @clientId + ':' + ev, data

        receiveSocketEvent: (ev, data) =>
            @trigger ev, data