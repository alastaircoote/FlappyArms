define [
    "jquery"
    "server/player"
    "libs/microevent"
], ($, Player) ->
    class Scoreboard extends MicroEvent
        constructor: (@players) ->
            @$el = $("#score-board")
            
            @playerEls = @players.map (p, i) =>
                p.on "flap", @playerStartAgain
                inner = $("<div class='inner scores'></div>")
                birdIcon = $("<div class='birdicon'/>")

                color = Player.getColorFromIndex(i)

                birdIcon.addClass color + "-bird"

                inner.append birdIcon, """
                    <div class='flapboxes'><div class='flap-1'/><div class='flap-2'/><div class='flap-3'/></div>
                    <p class='score'>#{p.score} point#{if p.score != 1 then 's' else ''}</p>
                    <p class='player'>Player #{i+1}</p>
                    <p class='ready-to-restart'>Player #{i+1} - flap three times!</p>
                    
                """
                return $("<div class='redbox playerbox player#{i+1} #{color}'></div>").append(inner)

            @$el.empty().append @playerEls

        playerStartAgain: (player) =>
            index = @players.indexOf player
            $(".inner",@playerEls[index]).attr "class", "inner ready-to-restart"

