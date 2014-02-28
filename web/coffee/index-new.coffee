gyro = window.returnExports

table = $("<table/>")

$("body").append(table)

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

document.ontouchstart = (e) ->
    console.log e.target
    e.stopPropagation()
    if e.target == document.body
        e.preventDefault()
    if e.touches.length > 1 then return
    console.log "touchstart"
    maxZ = 0
    minZ = 0
    gyro.startTracking (o) ->

        lastFive.push o

        #if lastFive.length < 5 then return

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
        
        console.log rounded.z

        #if old?.z != rounded.z then console.log rounded

        old = rounded
        if rounded.z < minZ then minZ = rounded.z
        if rounded.z > maxZ then maxZ = rounded.z

        if rounded.z >= -minZ
            
            if minZ < -3

                #sanity check
                if Date.now() - lastFlap < 200 then return

                lastFlap = Date.now()
                console.log "flapperated"

                $("body").trigger ("flap")
                if navigator.vibrate then navigator.vibrate(100)

            maxZ = 0
            minZ = 0
        #else if rounded.z <= -maxZ
            #console.log "huh"
            #maxZ = 0
            #minZ = 0




document.ontouchend = () ->
    console.log "end"
    gyro.stopTracking()