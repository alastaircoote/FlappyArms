define ["libs/microevent"], (MicroEvent) ->
    class SockJSEvented extends MicroEvent
        constructor: (@socket) ->
            @socket.onmessage = @processMsg
            @socket.onopen = =>
                @trigger "connect"
            @socket.onclose = =>
                @trigger "disconnect"
        
        processMsg: (e) =>
            json = JSON.parse(e.data)
            console.log "receive", json.ev, json.data
            @trigger json.ev, json.data
            @trigger "event", json.ev, json.data

        emit: (ev,data) =>
            console.log "emit", ev, data
            jsonString = JSON.stringify
                ev: ev
                data: data

            @socket.send jsonString