define ["comm-layer","servers","logger"], (CommLayer,servers, Logger) ->
    class ClientCommLayer extends CommLayer
        constructor: ->
            @on "receive", @receive
            @on "socketio-connected", =>
                Logger.info "Sending pair request for ##{@hostId}..."
                @socket.emit "is-client", {code: @hostId}

        connect: (id) =>
            @serverIndex = parseInt(id.substr(0,1), 10) - 1
            @hostId = id.substr(1)
            Logger.info "Connecting to socket.io server ##{@serverIndex}..."

            @connectSocketIO @serverIndex

        receive: (data) =>
            console.log data
            if data.ev == "no-host"
                alert "Could not find a host with that ID. Please try again - maybe reload the other device?"
                