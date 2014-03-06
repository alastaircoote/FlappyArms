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


module.exports = class HostClient
    @get: (id) ->
        return savedSockets.get(id)

    constructor: (@hostSocket) ->
        @id = savedSockets.add @
        @sendToHost {ev: "receive-id", id: @id,serverTime: Date.now()}
        @hostSocket.on "attach-peerid", @attachPeerId

    attachPeerId: (id) =>
        # If possible we want to elevate to WebRTC. Store this ID
        # to return to the client.
        console.log "Storing peer ID", id
        @peerId = id

    sendToHost: (data) =>
        @hostSocket.emit "receive", data

    sendToClient: (data) =>
        @clientSocket.emit "receive", data

    attachClient: (@clientSocket) =>
        @sendToHost {ev: "client-attached"}
        @sendToClient {ev: "host-attached", peerId: @peerId, serverTime: Date.now()}

        @clientSocket.on "disconnect", => @disconnected("client")
        @hostSocket.on "disconnect", => @disconnected("host")

        @clientSocket.on "send", (data) => @sendToHost(data)
        @hostSocket.on "send", (data) => @sendToClient(data)

    disconnected: (from) =>
        if @alreadyDisconnected == true then return
        @alreadyDisconnected = true
        console.log "discon", @hostSocket.disconnected, @clientSocket.disconnected
        if from == "client" && !@hostSocket.disconnected
            @hostSocket.disconnect()
            @hostSocket = null
        else if !@clientSocket.disconnected
            @clientSocket.disconnect()
            @clientSocket = null
        savedSockets.remove @