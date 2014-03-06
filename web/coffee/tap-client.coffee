define ["jquery","flap","servers","client-comm"], ($, flap, servers, ClientCommLayer) ->
    class Client
        isIos: (()->
            return /(iPad|iPod|iPhone)/.test(window.navigator.userAgent)
        )()
        constructor: ->
            $("body").addClass("client")

            @connectForm = $("#clientsub")
            @commLayer = new ClientCommLayer()
            @connectForm.on "submit", @connect

            if @isIos
                # iOS's 'shake to undo' feature totally ruins any accelerometer reading.
                # so we actually have to disallow text input, and display it ourselves
                $('#codenum').on "keydown", @keydowned
                $("#codenum").on 'focus', =>
                    @currentNum = ""
                    $('#nums').html ""

            @currentNum = ""
            flap()

            $("body").on "flap", =>
                console.log "touched"
                if @connected
                    @socket.emit "send", {ev: "toucherated", time:Date.now()}
                else
                    console.log "Flap while not connected."

            # iOS has some weird buggyness where it'll scroll at times. If it does, reset it
            # back again.
            $(window).on "scroll", ->
                $(window).scrollTop(0)

        connect: (e) =>
            console.log "do connect"
            e.preventDefault()
            val = $('#codenum').val()
            if @isIos
                val = @currentNum

            
            @commLayer.connect val
            return


            key = parseInt val.substr(0,1), 10
            console.log key, val.substr(1)
            if !servers.socketio[key-1]
                return @noHost()
            @socket = io.connect servers.socketio[key-1]
            console.log "connecting"
            @socket.on "connect", =>
                @connected = true
                console.log "connected"
                @socket.emit "is-client", {code: val.substr(1)}
            @socket.on "disconnect", =>
                console.log "disconnected"
                @connected = false
            @socket.on "receive", @receive

        receive: (data) =>
            console.log data
            if data.ev == "host-attached"
                return @gotHost()
            if data.ev == "host-disconnected"
                $("#client_intro").show()
                $('#client_play').hide()
                $("body").removeClass "doflap touched"
                @socket.disconnect()
            if data.ev == "no-host"
                @noHost()
                @socket.disconnect()
            #window.location.reload()

        noHost: ->
            alert "Sorry, we couldn't find a partner with that ID. Try reloading both browsers."

        keydowned: (e) =>

            e.preventDefault()
            e.stopPropagation()
            if e.keyCode == 8
                @currentNum = @currentNum.substr 0, @currentNum.length - 1
            else if e.keyCode >= 48 and e.keyCode <= 57
                @currentNum += String.fromCharCode(e.keyCode)
            $('#nums').html @currentNum
        keypressed: (e) =>
            console.log e, typeof e.keyCode
            e.preventDefault()
            e.stopPropagation()
            if [53,8].indexOf(e.keyCode) > -1

                @currentNum = @currentNum.substr 0, @currentNum.length - 2
            else if e.keyCode >= 48 and e.keyCode <= 57
                @currentNum += String.fromCharCode(e.keyCode)

            $('#nums').html @currentNum

        gotHost: =>
            $("#client_intro").hide()
            $('#client_play').show()
            $("body").addClass "doflap"
            console.log "got host", arguments


            

