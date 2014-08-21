define ["libs/gyro"], (gyro) ->

    return ->
        isOn = false
        old = null
        gyro.frequency = 10
        lastFive = []

        avg = (arr) ->
            t = 0
            for i in arr
                t += i
            return t / arr.length

        maxZ = 0
        minZ = 0

        lastFlap = 0

        document.ontouchmove = (e) ->
            e.preventDefault()


        currentState = ""
        document.ontouchstart = (e) ->
            if !$("body").hasClass("doflap") then return
            $("body").addClass "touched"
            e.stopPropagation()
            #if e.target == document.body
                #e.preventDefault()
            if e.touches.length > 1 then return
            maxZ = 0
            minZ = 0
            gyro.startTracking (o) ->



                lastFive.push o

                if lastFive.length < 5 then return

                avgVals =
                    x: avg lastFive.map (o) -> o.x
                    y: avg lastFive.map (o) -> o.y
                    z: avg lastFive.map (o) -> o.z


                lastFive = []


                rounded = 
                    x: Math.round(avgVals.x)
                    y: Math.round(avgVals.y)
                    z: Math.round(avgVals.z)

                rounded = 
                    x: Math.round(o.x)
                    y: Math.round(o.y)
                    z: Math.round(o.z)
                

                

                if currentState == "positive" and rounded.z < 0
                    #console.log "DO RESET"
                    minZ = 0
                    #maxZ = 0
                else

                    currentState = if rounded.z < 0 then "negative" else "positive"

                #if old?.z != rounded.z then console.log rounded

                old = rounded
                if rounded.z < minZ then minZ = rounded.z
                if rounded.z > maxZ then maxZ = rounded.z

                #console.log rounded.z, minZ, maxZ

                if rounded.z >= -minZ and minZ < 0 and maxZ > 0
                    console.log "maybe flap", minZ, maxZ
                    if maxZ > 10

                        #sanity check
                        if Date.now() - lastFlap < 500 then return

                        lastFlap = Date.now()

                        setTimeout () ->
                            maxZ = 0
                            minZ = 0
                        , 500
                        #if navigator.vibrate then navigator.vibrate(100)

                        maxZ = 0
                        minZ = 0

                        $("body").trigger ("flap")
                #else if rounded.z <= -maxZ
                    #console.log "huh"
                    #maxZ = 0
                    #minZ = 0




        document.ontouchend = () ->
            $("body").removeClass "touched"
            gyro.stopTracking()