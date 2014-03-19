define [
    "./anim-canvas"
    "image!assets/bird.png"
    "image!assets/bird_blue.png"
    "image!assets/bird_red.png"
    "image!assets/bird_green.png"
], (AnimateCanvas, birdOriginal, birdBlue, birdRed, birdGreen) ->
    class BirdCanvas extends AnimateCanvas
        width: 34
        height: 34
        duration: 500
        startLeft: 60
        startTop: 180

        jump: -4.6
        gravity: 0.15
        updateRate: 1000.0 / 60.0

        constructor: (@game, color) ->

            if !color then @image = birdOriginal
            else if color == "red" then @image = birdRed
            else if color == "blue" then @image = birdBlue
            else if color == "green" then @image = birdGreen
            console.log "img", @image
            @currentStep = -1
            super({})
            @velocity = 0
            @rotation = 0
            
            @status = "alive"
            @left = @startLeft
            @top = @startTop

        start: () =>
            @lastUpdateTime = Date.now()
            @started = true
            #$("body").on "click", @flap
            @flap()

        flap: () =>
            if @status != "alive" then return
            @velocity = @jump

        calculatePosition: (percentThrough, timeStamp) =>
            #console.log @status
            if @status == "dead-and-gone"
                # We're dead and off the screen. Don't do anything
                return

            
            if @status == "dead" then @moveDeadBird(timeStamp)
            else if @started then @moveBird(percentThrough)
            @drawImageStep(percentThrough)

        moveDeadBird: (timeStamp) =>
            landCanvasSpeed = @game.landCanvas.duration / @game.landCanvas.moveBy
            deadBirdMoveDuration = landCanvasSpeed * @startLeft

            percentComplete = (timeStamp - @timeOfDeath) / deadBirdMoveDuration
            if Math.abs(percentComplete) >= 1.5

                @doNotDraw = true
                @status = "dead-and-gone"
                return
            @left = @startLeft + ((@startLeft) * percentComplete)
            @deadBirdFall()

        deadBirdFall: () =>

            fallTarget = @game.landTop - @height + 5
            if @top == fallTarget then return

            distanceToFall = @game.landTop - @hitArea.bottom 
            timeToFall = distanceToFall * 40
            targetTime = @timeOfDeath + timeToFall

            timeSoFar = Date.now() - @timeOfDeath

            

            soFar = timeSoFar / timeToFall

            @top += distanceToFall * soFar

            rotationDifference = 90 - @rotationAtDeath
            @rotation += (rotationDifference * soFar)
            if @rotation > 90 then @rotation = 90

            if @top > fallTarget
                @top = fallTarget
                console.log "dead complete"
            
        calculateHitArea: () =>
            hitwidth = @width - (Math.sin(Math.abs(@rotation) / 90) * 8)
            hitheight = 24 + (Math.sin(Math.abs(@rotation) / 90) * 8)
            @hitArea =
                width: hitwidth
                height: hitheight
                top: @top + ((@height - hitheight) / 2)
                left: @left + ((@width - hitwidth) / 2)

            @hitArea.bottom = @hitArea.top + @hitArea.height
            @hitArea.right = @hitArea.left + @hitArea.width


        moveBird: (percentThrough) =>
            timeSinceLastUpdate = Date.now() - @lastUpdateTime
            ofUpdateRate = timeSinceLastUpdate / @updateRate

            
            @velocity += @gravity * ofUpdateRate
            @top += @velocity * ofUpdateRate
            @rotation = Math.min(Math.floor((@velocity / 10) * 90), 90)
            @calculateHitArea()

            if @hitArea.bottom > @game.landTop
                @top = @game.landTop - @height + 5
                @kill()

            

            @lastUpdateTime = Date.now()

        kill: () =>
            @status = "dead"
            @trigger "dead"
            @timeOfDeath = Date.now()
            @rotationAtDeath = @rotation
            #@started = false

        drawImageStep: (percentThrough) =>
            # If we're dead, stop flapping
            if @status != "alive" then step = @currentStep
            else
                # Otherwise, step through the 4 steps of flapping
                step = Math.floor percentThrough * 8
                if step >= 4 then step -= 4
            
            if @currentStep == step and @lastRotation == @rotation then return

            @lastRotation = @rotation
            @calculateHitArea()
            
            @currentStep = step
            @context.save()
            #@context.fillStyle = "blue"
            @context.clearRect 0,0, @width + 10, @height + 10
            #@context.fillRect @hitArea.left - @left, @hitArea.top - @top, @hitArea.width, @hitArea.height
            
            @context.translate @width / 2, @height / 2

            @context.rotate @rotation * Math.PI / 180

            @context.drawImage @image,0,(24 * step),34,24, -(@width / 2), -(@height / 2) + 5, 34, 24

            @context.restore()


            