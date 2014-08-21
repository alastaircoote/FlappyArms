define ["libs/microevent",'logger'], (MicroEvent, Logger) ->
    class SockJSEvented extends MicroEvent
        constructor: (@socket) ->
            @socket.onmessage = @processMsg
            @socket.onopen = =>
                @trigger "connect"
            @socket.onclose = =>
                @trigger "disconnect"
        
        processMsg: (e) =>
            json = JSON.parse(e.data)
            Logger.info "receive", json.ev, json.data
            @trigger json.ev, json.data
            @trigger "event", json.ev, json.data

        emit: (ev,data) =>
            Logger.info "emit", ev, data
            jsonString = JSON.stringify
                ev: ev
                data: data

            @socket.send jsonString

        close: =>
            @socket.close()