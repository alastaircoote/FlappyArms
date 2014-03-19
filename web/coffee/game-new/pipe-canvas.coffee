define [
    "./anim-canvas"
    "image!assets/pipe.png"
    "image!assets/pipe-up.png"
    "image!assets/pipe-down.png"
], (AnimCanvas, pipeImage, pipeUpImage, pipeDownImage) ->
    class PipeCanvas extends AnimCanvas
        @pipeGap: 120
        @width: 52
        @buffer: 30

        makeNewPipe: 200
        loop: false

        duration: 5000

        @pipeTemplate: null

        constructor: (opts, @game) ->
            super(opts)
            landSpeed = @game.landCanvas.duration / @game.landCanvas.moveBy
            @duration = landSpeed * opts.moveBy
            @madeNewPipe = false

        @createPipeTemplate: () ->
            console.log "creating pipe template"
            drawHeight = @baseHeight * 2
            canvas = $("<canvas/>")[0]
            context = canvas.getContext("2d")
            canvas.width = @width
            canvas.height = drawHeight

            pipeHeight = (drawHeight / 2) - (@pipeGap / 2)
            topOfBottom = (drawHeight / 2) + (@pipeGap / 2)

            context.fillStyle = context.createPattern(pipeImage,"repeat-y")
            context.fillRect 0,0,@width, pipeHeight - pipeDownImage.height

            context.drawImage pipeDownImage, 0, pipeHeight - pipeDownImage.height

            context.fillRect 0,topOfBottom + pipeUpImage.height, @width, pipeHeight

            context.drawImage pipeUpImage, 0, topOfBottom

            @pipeTemplate = canvas

        createCanvas: =>
            if PipeCanvas.pipeTemplate == null
                PipeCanvas.createPipeTemplate()
            @canvas = PipeCanvas.pipeTemplate

            @top = -(PipeCanvas.baseHeight - @height)
            @top -= @height / 2

            varyAmount = (@height / 2) - (PipeCanvas.pipeGap / 2) - PipeCanvas.buffer
            
            random = Math.floor ((varyAmount * 2) * Math.random()) - varyAmount
            @top += random

        calculatePosition: (now) =>
            super(now)
            if @moveByPosition <= @moveBy + 90 + PipeCanvas.width && @moveByPosition >= @moveBy + 60
                @trigger "hitCheck"
            if @moveByPosition < -@makeNewPipe && @madeNewPipe == false
                @trigger "makeNewPipe"
                @madeNewPipe = true

        hitCheck: (birds) =>
            mid = @top + (@canvas.height/2)
            top = mid - (PipeCanvas.pipeGap / 2)
            bottom = mid + (PipeCanvas.pipeGap / 2)

            for bird in birds
                if bird.hitArea.bottom > bottom or bird.hitArea.top < top
                    bird.kill()


