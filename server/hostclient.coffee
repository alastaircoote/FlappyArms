savedSockets = {
    stored: {}
    add: (toSave) ->
        keys = Object.keys(@stored)
        code = Math.round(Math.random() * 1000)
        while keys.indexOf(code) > 0
            # Get new ID
            code = Math.round(Math.random() * 1000)

        @stored[code] = toSave
        return code

    get: (id) ->
        return @stored[id]

    remove: (toRemove) ->
        delete @stored[toRemove.id]
        console.log "disconnected, now #{Object.keys(@stored).length} clients..."
}


module.exports = class Host
    @get: (id) ->
        return savedSockets.get(id)

    constructor: (@hostSocket) ->
        @id = savedSockets.add @
        @clients = {}
        @sendToHost "receive-id", {id: @id}
        @hostSocket.on "attach-peerid", @attachPeerId

    attachPeerId: (id) =>
        # If possible we want to elevate to WebRTC. Store this ID
        # to return to the client.
        console.log "Storing peer ID", id
        @peerId = id

    sendToHost: (ev,data) =>
        @hostSocket.send ev, data

    sendToClient: (id,ev, data) =>
        @clients[id].send ev, data

    attachClient: (clientSocket) =>
        id = 0
        while @clients[id]
            id++

        @clients[id] = clientSocket

        @sendToHost 'client-attached',{clientId: id}
        @sendToClient id, "host-attached", {peerId: @peerId, clientId: id}

        clientSocket.on "disconnect", =>
            @clientDisconnected(id)
        @hostSocket.on "disconnect", =>
            @hostDisconnected()

        clientSocket.on "received", (data) => @sendToHost(data.ev, data.data)
        @hostSocket.on "received", (data) => 
            evSplit = data.ev.split(':')
            if evSplit.length == 2
                @sendToClient(Number(evSplit[0]),evSplit[1], data.data)

    hostDisconnected: () =>
        for key, val of @clients
            @sendToClient key, 'disconnected'
        @hostSocket.disconnect()
        @hostSocket = null
        savedSockets.remove @

    clientDisconnected: (id) =>
        delete @clients[id]
        @sendToHost 'disconnected', id