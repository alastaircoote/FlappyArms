define [
    "libs/microevent"
], (MicroEvent) ->
    class IntroBox extends MicroEvent
        constructor: () ->
            self = this
            @$el = $("#intro")
            $("#intro").on "mouseover", "li", ->
                $("#intro li.selected").removeClass("selected")
                $(this).addClass("selected")
            $("#intro").on "click", "li", () ->
                idx = $("#intro li").index(this)
                self.trigger "numPlayersChosen", idx + 1

        show: =>
            $("body").on "keydown", @introKeypress
            #$("#instruction-box").show()

        hide: =>
            $("body").off "keydown", @introKeypress
            @$el.hide()

        introKeypress: (e) ->
            selected = $("#intro li.selected")
            lis = $("#intro li")
            selectedIndex = lis.index selected

            targetEl = null

            if e.keyCode == 32 or e.keyCode == 13
                return selected.trigger "click"

            if e.keyCode == 38 or e.keyCode == 40
                if selectedIndex == 0 then targetEl = lis.get(2)
                if selectedIndex == 1 then targetEl = lis.get(3)
                if selectedIndex == 2 then targetEl = lis.get(0)
                if selectedIndex == 3 then targetEl = lis.get(1)

            if e.keyCode == 37 or e.keyCode == 39
                if selectedIndex == 0 then targetEl = lis.get(1)
                if selectedIndex == 1 then targetEl = lis.get(0)
                if selectedIndex == 2 then targetEl = lis.get(3)
                if selectedIndex == 3 then targetEl = lis.get(2)
            

            if targetEl
                selected.removeClass("selected")
            $(targetEl).addClass("selected")