define ["jquery","flap","client/player"], ($, flap, Player) ->
    class Client
        isIos: /(iPad|iPod|iPhone)/.test(window.navigator.userAgent)
        constructor: ->
            $("body").addClass("client")

            @connectForm = $("#clientsub")
            @player = new Player()
            @player.on 'server-full', @serverFull
            @player.on 'disonnected', -> window.onbeforeunload = null
            #@commLayer.on "receive", @receive
            #@commLayer.on "disconnected", @disconnected
            #@commLayer.on "badserver", () => @noHost()
            @connectForm.on "submit", @connect

            if @isIos
                # iOS's 'shake to undo' feature totally ruins any accelerometer reading.
                # so we actually have to disallow text input, and display it ourselves
                $('#codenum').on "keydown", @keydowned
                $("#codenum").on 'focus', =>
                    @currentNum = ""
                    $('#nums').html ""

            @currentNum = ""
            #flap()

            $("body").on "flap", =>
                console.log "touched", Date.now()
                @commLayer.send {ev: "toucherated", time:Date.now()}

            # iOS has some weird buggyness where it'll scroll at times. If it does, reset it
            # back again.
            #$(window).on "scroll", ->
            #    $(window).scrollTop(0)

        connect: (e) =>
            console.log "do connect"
            e.preventDefault()
            val = $('#codenum').val()
            if @isIos
                val = @currentNum

            @player.connect val

            window.onbeforeunload = () =>
                @player.disconnect()
                return 'Are you sure you want to exit the game?'

            return

        serverFull: =>
            alert "Sorry, this game is full."
            @player.disconnect()
            $('#codenum').val('')
            $('#nums').html ""
            @currentNum = ''
            $('#nums').focus()

        disconnected: () =>
            $("#client_intro").show()
            $('#client_play').hide()
            $("body").removeClass "doflap touched"
            $('#codenum').val("")

        receive: (data) =>
            if data.ev == "host-attached"
                return @gotHost()

            if data.ev == "no-host"
                @noHost()

        noHost: ->
            alert "Sorry, we couldn't find a partner with that ID. Try reloading both browsers."
            @commLayer.disconnect()

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
            $("body").addClass "doflap touched"
            console.log "got host", arguments
