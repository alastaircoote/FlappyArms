define [
    "libs/microevent"

], (MicroEvent) ->
    class Player extends MicroEvent
        useKbEvents: true
        constructor: (@comm, @index) ->
            @score = 0
        
            #if @useKbEvents
            #    @hookKbEvents()



        attachSocket: (@socketId) =>
            @connected = true
            @trigger 'got-socket', @
            @comm.onId @socketId, 'flap', =>
                @trigger "flap", @

            @comm.onId @socketId, 'disconnected', @disconnect
            @comm.onId @socketId, 'ping', (data) =>
                @comm.send @socketId, 'pong', data

            @comm.onId @socketId, 'ping-result', (pr) ->
                tr = $("#player_#{socketId+1}_info")
                tr.addClass 'active'
                if pr.rtc
                    tr.addClass 'rtc'
                else
                    tr.removeClass 'rtc'

                tr.find('td.ping').html pr.time
            #@comm.socket.on @socketId + ':ping', (data) =>
            #    @comm.socket.emit @socketId + ':pong', data

        hookKbEvents: () =>
            
            $(window).on "keydown", (e) =>
                keyCode = @index + 49
                if e.keyCode == 192 and !@id
                    e.stopImmediatePropagation()
                    return @assignId(1)

                if e.keyCode != keyCode then return
                
                if e.shiftKey
                    return @disconnect()
                else if @index == null
                    return   
                else
                    return @trigger "flap", @
                console.log e

        #setIndex: (@index) =>
            #@color = @getColorFromIndex(@idx)
        #    if @index != null and @index > -1 then @trigger "got-index", @
        #    @comm.on "player:#{@index}", @playerAction

        receivePlayerAction: (data) =>
            console.log 'player-data', data

        disconnect: () =>
            console.log "Player disconnected"
            @id = null
            @trigger "disconnect", @, @index
            @connected = false
            tr = $("#player_#{@socketId+1}_info")
            tr.attr 'class', ''
            tr.find('td.ping').html ''


        @getColorFromIndex: (idx) ->
            color = "orig"
            switch idx
                when 1 then color = "red"
                when 2 then color = "blue"
                when 3 then color = "green"

            return color

