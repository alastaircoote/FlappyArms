module.exports = class SockJSEvented extends require('events').EventEmitter
    constructor: (@socket) ->
        @socket.on "data", @processMsg
        @socket.on "open", => @emit "connect"
        @socket.on "close", => @emit "disconnect"
    
    processMsg: (msg) =>
        json = JSON.parse(msg)
        console.log "receive", json.ev, json.data
        @emit json.ev, json.data
        @emit 'received', json

    send: (ev,data) =>
        console.log "send", ev, data
        jsonString = JSON.stringify
            ev: ev
            data: data

        @socket.write jsonString