define ["jquery","game/main","host-comm","logger"], ($, Birdie, HostCommLayer,Logger) ->
    class Server
        constructor: ->
            @comm = new HostCommLayer()
            @comm.connect()

            @comm.on "id-received", @receiveId
            @comm.on "receive", @receive
            @comm.on "disconnected", @disconnected
            @comm.on "ping", (ping) ->
                #$("#spanPing").html(ping)
                #console.log "ping", ping

            $("#gamecontainer, #instruction-box").css "display","block"
            Birdie()
            @flapsSoFar = 0

            $("body").on "gameStarted", ->
                $("#bigscore").show()
                $("#instruction-box").hide()
                $("#howtoplay, #intro, h1").hide()

            $("body").on "gameover", @gameover

            Logger.on "info", (msg) ->
                $("#infobox").append $("<p/>").html(msg)
                $("#infobox").scrollTop 99999

            $("#infobutton").on "click", -> $("#infobox").toggle()

        gotClient: =>
            if $("#gameover").css("display") == "block" then return
            $("#intro").hide()
            $("#howtoplay, #signals").show()

        receiveId: (data) =>
            @socketId = data
            $("#numbers").html data

        receive: (data) =>
            if data.ev == "toucherated" then @flap(data)
            if data.ev == "client-attached" then @gotClient()

        flap: (data) =>
            @flapsSoFar++
            d = new Date()
            dFormat = d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds() + ":" + d.getMilliseconds()
            Logger.info "Received message at " + dFormat
            if @flapsSoFar == 1
                $("#signal1").addClass("active")
            else if @flapsSoFar == 2
                $("#signal2").addClass("active")
            else if @flapsSoFar == 3
                $("#signal3").addClass("active")
            else
                $("body").trigger "flap"


        gameover: (e, score) =>
            $("#bigscore").hide()
            $("#score").html score
            $("#gameover, #signals").show()
            $("#signals .signal.active").removeClass("active")
            $("#instruction-box").show()

            @flapsSoFar = 0

        disconnected: () =>
            $("#numbers").html ""
            @socketId = null
            $("#intro, #instruction-box, h1").show()
            $("#howtoplay, #signals, #gameover").hide()
            $("body").trigger "resetgame"
            @comm.connect()
