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

document.ontouchstart = () ->
    maxZ = 0
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
        if !old then return old = rounded

        console.log rounded

        if isOn and rounded.z > 12 
            console.log rounded.z, maxZ
            if rounded.z >= maxZ
                isOn = false
                maxZ = 0
                return navigator.vibrate(200)
            else
                isOn = false
                maxZ = 0

        if rounded.z > maxZ then maxZ = rounded.z

   
        if rounded.z < 0
            isOn = true
            #navigator.vibrate(200)

        old = rounded

        #console.log o

document.ontouchend = () ->
    console.log "end"
    gyro.stopTracking()