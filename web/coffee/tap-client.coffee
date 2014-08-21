define ["jquery","flap","client/player"], ($, flap, Player) ->
    class Client
        isIos: /(iPad|iPod|iPhone)/.test(window.navigator.userAgent)
        constructor: ->
            $("body").addClass("client")

            @connectForm = $("#clientsub")
            @player = new Player()
            @player.on 'server-full', @serverFull
            @player.on 'disonnected', -> window.onbeforeunload = null
            @player.on 'connected', @gotHost
            @player.on 'no-host', @noHost
            @player.on 'disconnected', @disconnected
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
                @player.send 'flap'

            # iOS has some weird buggyness where it'll scroll at times. If it does, reset it
            # back again.
            #$(window).on "scroll", ->
            #    $(window).scrollTop(0)

            if window.location.href.indexOf("?connect=") > -1
                id = window.location.href.split('?connect=')[1]
                @connect(null, id)

        connect: (e, forceId) =>
            console.log "do connect"
            if (e) then e.preventDefault()
            val = $('#codenum').val()
            if @isIos
                val = @currentNum

            @player.connect forceId or val

            #window.onbeforeunload = () =>
            #    @player.disconnect()
            #    return 'Are you sure you want to exit the game?'

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
            e.preventDefault()
            e.stopPropagation()
            if [53,8].indexOf(e.keyCode) > -1

                @currentNum = @currentNum.substr 0, @currentNum.length - 2
            else if e.keyCode >= 48 and e.keyCode <= 57
                @currentNum += String.fromCharCode(e.keyCode)

            $('#nums').html @currentNum

        gotHost: (clientId) =>
            color = "orig"
            switch clientId
                when 1 then color = "red"
                when 2 then color = "blue"
                when 3 then color = "green"

            $("#touch-num").html clientId + 1
            $("#client_intro").hide()
            $('#client_play').addClass('player_' + color)
            $('#client_play').show()
            $("body").addClass "doflap"
            console.log $('#touchtarget').height()
            #$('#touchtarget').css
            #    top: $(window).height() - $('#touchtarget').height()
            window.scrollTo 0,0
            flap()
            
