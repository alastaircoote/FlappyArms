define [
    "jquery"
    "host-comm"
    "logger"
    "game-new/game"
    "server/connect-window"
    "libs/microevent"
    ], ($, HostCommLayer, Logger, GameCanvas, ConnectWindow, MicroEvent) ->
    class Server extends MicroEvent
        constructor: ->
            
            @connectWindow = new ConnectWindow(@)

            $("#gamecontainer, #instruction-box").css "display","block"
            
            @gc = new GameCanvas({
                width: $(window).width()
                height: $(window).height()
            })

            $("window").on "resize", () =>
                @gc.setOptions({
                    width: $(window).width()
                    height: $(window).height()
                });

            @gc.el.css
                position:"absolute"
                left: "0%"
                top:0

            $("body").append @gc.el

            @setIntroBox()


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

        setIntroBox: =>
            self = this
            $("#intro").on "mouseover", "li", ->
                $("#intro li.selected").removeClass("selected")
                $(this).addClass("selected")
            $("#intro").on "click", "li", () ->
                idx = $("#intro li").index(this)
                self.numOfPlayers = idx + 1
                self.showConnectWindow()
            @showIntroBox()
        
        showIntroBox: =>   
            $("body").on "keydown", @introKeypress
            $("#instruction-box").show()

        showConnectWindow: =>
            @hideAll()
            @connectWindow.show()
            
            @connectEls = [1..@numOfPlayers].map (i) ->


            #$("#connect-box").show()
            @connect()

        hideAll: =>
            # Sort of a catch all to disable and hide everything, no
            # matter where we are.
            @connectWindow.hide()
            $("#instruction-box").hide()
            $("body").off "keydown", @introKeypress


        connect: =>
            @comm = new HostCommLayer()
            @comm.connect()

            @comm.on "id-received", (id) =>
                @trigger "id-received", id
            @comm.on "receive", @receive
            @comm.on "disconnected", @disconnected
            @comm.on "ping", (ping) ->
                #$("#spanPing").html(ping)
                #console.log "ping", ping

        startGame: (numPlayers) =>
            console.log numPlayers
            @hideAll()
            @gc.addBirds(numPlayers)


        introKeypress: (e) ->
            selected = $("#intro li.selected")
            lis = $("#intro li")
            selectedIndex = lis.index selected

            targetEl = null

            if e.keyCode == 32 or e.keyCode == 13
                return selected.trigger "click"

            if e.keyCode == 38 or e.keyCode == 40
                if selectedIndex == 0 then targetEl = lis.get(2)
                if selectedIndex == 1 then targetEl = lis.get(3)
                if selectedIndex == 2 then targetEl = lis.get(0)
                if selectedIndex == 3 then targetEl = lis.get(1)

            if e.keyCode == 37 or e.keyCode == 39
                if selectedIndex == 0 then targetEl = lis.get(1)
                if selectedIndex == 1 then targetEl = lis.get(0)
                if selectedIndex == 2 then targetEl = lis.get(3)
                if selectedIndex == 3 then targetEl = lis.get(2)
            

            if targetEl
                selected.removeClass("selected")
            $(targetEl).addClass("selected")

        gotClient: =>
            if $("#gameover").css("display") == "block" then return
            $("#intro").hide()
            $("#howtoplay, #signals").show()

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
