define [
    "./anim-canvas"
    "image!assets/pipe.png"
    "image!assets/pipe-up.png"
    "image!assets/pipe-down.png"
], (AnimCanvas, pipeImage, pipeUpImage, pipeDownImage) ->
    class PipeCanvas extends AnimCanvas
        @pipeGap: -1
        @width: 52
        @buffer: 30

        @makeNewPipe: -1
        loop: false

        duration: 5000

        @pipeTemplate: null

        @resetPositions: () ->
            PipeCanvas.pipeGap = 170
            PipeCanvas.makeNewPipe = 300
        
        @upLevel: () ->
            if PipeCanvas.pipeGap >= 90
                PipeCanvas.pipeGap -= 5
            if PipeCanvas.makeNewPipe >= 60
                PipeCanvas.makeNewPipe -= 10

        constructor: (opts, @game) ->
            # store the current gap for hit calculations
            @thisPipeGap = PipeCanvas.pipeGap
            super(opts)
            landSpeed = @game.landCanvas.duration / @game.landCanvas.moveBy
            @duration = landSpeed * opts.moveBy
            @madeNewPipe = false
            @hasScored = false
            
            

        @pipeTemplates: {}
        @createPipeTemplate: (pipeGap) ->
            #drawHeight = @baseHeight * 2
            canvas = $("<canvas/>")[0]
            context = canvas.getContext("2d")
            canvas.width = @width
            canvas.height = @drawHeight * 2

            pipeHeight = (canvas.height / 2) - (pipeGap / 2)
            topOfBottom = (canvas.height / 2) + (pipeGap / 2)
            context.fillStyle = context.createPattern(pipeImage,"repeat-y")

            context.fillRect 0,0,@width, pipeHeight - pipeDownImage.height

            context.drawImage pipeDownImage, 0, pipeHeight - pipeDownImage.height

            context.fillRect 0,topOfBottom + pipeUpImage.height, @width, pipeHeight

            context.drawImage pipeUpImage, 0, topOfBottom

            PipeCanvas.pipeTemplates[pipeGap] = canvas
            

        createCanvas: =>
            if !PipeCanvas.pipeTemplates[@thisPipeGap]
                PipeCanvas.createPipeTemplate(@thisPipeGap)
            @canvas = PipeCanvas.pipeTemplates[@thisPipeGap]
            @top = -(PipeCanvas.drawHeight / 2)

            # bottom of top
            @top -= (PipeCanvas.drawHeight - @thisPipeGap) / 2
            @top += PipeCanvas.buffer
            #@top -= @height / 2

            canVaryBy = PipeCanvas.drawHeight - (PipeCanvas.buffer * 2) - @thisPipeGap

            @top += Math.floor canVaryBy * Math.random()

            varyAmount = @height - @thisPipeGap# - PipeCanvas.buffer
            
            #random = Math.floor ((varyAmount * 2) * Math.random()) - varyAmount
            #@top += varyAmount #random

        calculatePosition: (now) =>
            super(now)
            if @moveByPosition <= @moveBy + 90 + PipeCanvas.width && @moveByPosition >= @moveBy + 60
                @trigger "hitCheck"
            if @moveByPosition < -PipeCanvas.makeNewPipe && @madeNewPipe == false
                @trigger "makeNewPipe"
                @madeNewPipe = true
            if (@left + @moveByPosition  <= @pointPosition - PipeCanvas.width) && !@hasScored
                @hasScored = true
                @game.scored()

        hitCheck: (birds) =>
            mid = @top + (@canvas.height/2)
            top = mid - (@thisPipeGap / 2)
            bottom = mid + (@thisPipeGap / 2)

            for bird in birds
                if bird.hitArea.bottom > bottom or bird.hitArea.top < top
                    bird.kill()


