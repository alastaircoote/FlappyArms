define [
    "jquery"
    "./anim-canvas"
    "./bird-canvas"
    "./pipe-canvas"
    "image!assets/land.png"
    "image!assets/sky.png"
], ($, AnimateCanvas, BirdCanvas, PipeCanvas, landImage, skyImage) ->
    class Game
        baseHeight: 460
        colors: [
            null
            "red"
            "blue"
            "green"
        ]
        constructor: (@opts) ->
            # Pass through here just so we store it once
            PipeCanvas.baseHeight = @baseHeight
            @createEl()
            @createPatterns()
            
            @birds = []
            @pipes = []
            #@addBirds(4)
            
            
            @deadBirds = 0

            @landTop = @landCanvas.top
            ###
            $("body").one "click", () =>
                @addPipe()
                $("body").on "click", () =>
                    @birds[0].flap()
                $("body").on "keypress", () =>
                    @birds[1].flap()

                @birds.forEach (b) -> b.start();

            ###

            @animate()

        addBirds: (i) =>
            [1..i].map => @addBird()

            for bird, x in @birds
                bird.top = bird.top - (bird.height * x)

        addBird: () =>
            self = this
            bird = new BirdCanvas(@, @colors[@birds.length])
            bird.on "dead", () ->
                self.birdDied this
            @birds.push bird

        setOptions = (@opts) =>
            @calcSize()

        createEl: =>
            @el = $("<canvas/>")
            @calcSize()

        calcSize: () =>
            heightProp = @baseHeight / @opts.height
            @calcWidth = Math.round @opts.width * heightProp
            
            @el.attr
                width: @calcWidth
                height: @baseHeight
            @el.css
                width: @opts.width
                height: @opts.height
            @context = @el[0].getContext("2d")
            @context.fillStyle = '#4EC0CA'

        createPatterns: =>
            landHeight = landImage.height - 60
            @landCanvas = new AnimateCanvas
                width: @calcWidth
                height: landHeight
                image: landImage
                moveBy: -335
                duration: 3000
                left: 0
                top: @baseHeight - landHeight

            @skyCanvas = new AnimateCanvas
                width: @calcWidth
                height: skyImage.height
                image: skyImage
                moveBy: -275
                duration: 5500
                left: 0
                top: @baseHeight - landHeight - skyImage.height

        addPipe: () =>
            newPipe = new PipeCanvas {
                height: @baseHeight - @landCanvas.height
                top:0
                left: @calcWidth
                moveBy: -(@calcWidth + PipeCanvas.width)
                }, @

            newPipe.on "animationComplete", @pipeDone
            newPipe.on "hitCheck", @hitCheck
            newPipe.on "makeNewPipe", @addPipe

            @pipes.push newPipe 

        pipeDone: () =>
            console.log "pipe done"
            @pipes.splice 0, 1
            #@addPipe()

        hitCheck: () =>
            oldFill = @context.fillStyle
            @context.fillStyle = "blue"
            @context.fillRect 0,0,20,20
            @context.fillStyle = oldFill
            @pipes[0].hitCheck @birds.filter (b) -> b.status == "alive"

        birdDied: (bird) =>
            # Do not eat
            @deadBirds++
            if @deadBirds == @birds.length

                @pauseTime = Date.now()


        animate: =>
            AnimateCanvas.startTime = Date.now()
            loopFunc = =>
                now = @pauseTime or Date.now()


                AnimateCanvas.calculatePositions now

                @draw()
                if !@stopAnimation then window.requestAnimationFrame loopFunc
                #setTimeout loopFunc, 500

            loopFunc()

        draw: =>

            @context.fillRect 0,0, @calcWidth, @baseHeight
            
            @skyCanvas.drawOn @context
            
            @pipes.forEach (p) =>
                p.drawOn @context

            @birds.forEach (b) =>
                b.drawOn @context

            @landCanvas.drawOn @context

