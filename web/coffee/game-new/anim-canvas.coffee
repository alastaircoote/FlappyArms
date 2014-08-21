define ["jquery", "libs/microevent"], ($, MicroEvent) ->

    allCanvases = []

    class AnimateCanvas extends MicroEvent
        moveByPosition: 0
        scale: 1
        constructor: (opts) ->
            @startTime = Date.now()
            for key, val of opts
                @[key] = val
            @createCanvas()
            allCanvases.push @

        createCanvas: () =>
            canvas = $("<canvas/>")
            widthToDraw = @width + Math.abs(@moveBy)
            canvas.attr
                width: widthToDraw * @scale
                height: @height * @scale
            context = canvas[0].getContext("2d")
            context.scale @scale, @scale
            context.rect 0, 0, widthToDraw, @height
            context.fillStyle = context.createPattern(@image,"repeat")
            context.fill()
            @canvas = canvas[0]
            @context = context

        drawOn: (ctx, x, y) =>
            if @doNotDraw then return

            leftPos = @left
            if @moveByPosition then leftPos += @moveByPosition

            ctx.drawImage @canvas, leftPos, @top

        calculatePosition: (percentThrough) =>
            @moveByPosition = Math.floor @moveBy * percentThrough

        @calculatePositions: (time) ->
            

            for canvas in allCanvases
                timeDiff = time - canvas.startTime
                numThrough = Math.floor timeDiff / canvas.duration
                if canvas.loop == false && numThrough > 0 && !canvas.stopped
                    allCanvases.splice allCanvases.indexOf(canvas), 1
                    return canvas.trigger "animationComplete"

                pos = timeDiff - (canvas.duration * numThrough)
                percentThrough = pos / canvas.duration
                if !canvas.stopped
                    canvas.calculatePosition(percentThrough, time)
