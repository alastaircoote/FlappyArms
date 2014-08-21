define [
    "image!assets/font_big_0.png"
    "image!assets/font_big_1.png"
    "image!assets/font_big_2.png"
    "image!assets/font_big_3.png"
    "image!assets/font_big_4.png"
    "image!assets/font_big_5.png"
    "image!assets/font_big_6.png"
    "image!assets/font_big_7.png"
    "image!assets/font_big_8.png"
    "image!assets/font_big_9.png"
], () ->
    class ScoreBox
        constructor: () ->
            @$el = $("#score-box")
            @currentNum = 0

        increment: () ->
            @currentNum++
            digits = String(@currentNum)
            els = []
            for i in [0..digits.length-1]
                d = digits[i] 
                els.push "<img src='assets/font_big_#{d}.png'/>"

            @$el.html els

        show: () =>
            @$el.show()

        hide: () =>
            @$el.hide()