define [
    "jquery"
    "./anim-canvas"
    "./bird-canvas"
    "./pipe-canvas"
    "image!assets/land.png"
    "image!assets/sky.png",
    "./score-box",
    "libs/microevent"
], ($, AnimateCanvas, BirdCanvas, PipeCanvas, landImage, skyImage, ScoreBox, MicroEvent) ->
    class Game extends MicroEvent
        baseHeight: 460
        colors: [
            null
            "red"
            "blue"
            "green"
        ]
        constructor: (@opts) ->
            AnimateCanvas.reset()
            # Pass through here just so we store it once
            PipeCanvas.baseHeight = @baseHeight
            @createEl()
            @createPatterns()
            
            
            #@addBirds(4)
            @birds = []
            @pipes = []
            @deadBirds = 0
            @currentScore = 0
            

            @landTop = @landCanvas.top
            @scoreBox = new ScoreBox()
            @animate()

        reset: =>
            @birds = []
            @pipes = []
            @deadBirds = 0
            @currentScore = 0
            @pauseTime = null
            @stopAnimation = false
            @animate()


        start: () =>
            PipeCanvas.resetPositions()
            @birds.forEach (b) -> b.start()
            @addPipe()
            @scoreBox.show()

        addBird: () =>
            self = this
            bird = new BirdCanvas(@, @colors[@birds.length])
            bird.on "dead", () ->
                self.birdDied this

            bird.top += bird.height * @birds.length
            @birds.push bird

            return bird

        flapBird: (i) =>
            @birds[i].flap()

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
            PipeCanvas.drawHeight = @baseHeight - landHeight
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
                pointPosition: 60
                }, @

            newPipe.on "animationComplete", @pipeDone
            newPipe.on "hitCheck", @hitCheck
            newPipe.on "makeNewPipe", @addPipe

            @pipes.push newPipe 

        pipeDone: () =>
            @pipes.splice 0, 1
            #@addPipe()

        scored: () =>
            PipeCanvas.upLevel()
            @scoreBox.increment()
            @trigger "scored"

        hitCheck: () =>
            @pipes[0].hitCheck @birds.filter (b) -> b.status == "alive"

        birdDied: (bird) =>
            # Do not eat
            @deadBirds++
            if @deadBirds == @birds.length
                @pauseTime = Date.now()
                bird.on "deadcomplete", () =>
                    setTimeout @gameOver, 500

        gameOver: () =>
            @scoreBox.hide()
            @trigger "gameover"
            console.log 'gameover'
            @stopAnimation = true

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

