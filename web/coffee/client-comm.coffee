define ["comm-layer","servers","logger"], (CommLayer,servers, Logger) ->
    class ClientCommLayer extends CommLayer
        constructor: ->
            #@on "receive", @receive
            @on "connections-complete", =>
                Logger.info "Sending pair request for ##{@hostId}..."
                @socket.emit "is-client", {code: @hostId}

            super()

        connect: (id) =>
            @serverIndex = parseInt(id.substr(0,1), 10) - 1
            @hostId = id.substr(1)
            Logger.info "Connecting to socket.io server ##{@serverIndex}..."

            @connectSocketIO @serverIndex

        receive: (data) =>

            