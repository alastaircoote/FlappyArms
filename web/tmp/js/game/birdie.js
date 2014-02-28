(function() {
  var init;

  init = function() {
    var canvas, game, gamestarted;
    if (Modernizr.touch) {
      return;
    }
    canvas = $('canvas')[0];
    $(canvas).attr({
      width: $(canvas).width(),
      height: $(canvas).height()
    });
    game = new Game(canvas);
    game.entities = [new Background(game), game.obstacles = new Obstacles(game), game.bird = new Bird(game), game.score = new Score(game), game.ground = new Grass(game)];

    /*
    document.getElementById('play-again').addEventListener 'click', (e) ->
      e.stopPropagation()
      game.gameOver false
      $('canvas')[0].focus()
     */
    game.gameOver(false);
    game.draw();
    canvas.focus();
    window.game = game;
    gamestarted = false;
    return;
    return $("body").on("click", function() {
      if (!gamestarted) {
        gamestarted = true;
        return game.start();
      } else {
        game.keyPressed["space"] = {};
        game.keyPressed["space"]["keydown"] = true;
        game.keyPressed["space"]["keyup"] = false;
        return setTimeout(function() {
          game.keyPressed["space"] = {};
          game.keyPressed["space"]["keydown"] = false;
          return game.keyPressed["space"]["keyup"] = true;
        }, 20);
      }
    });
  };

  resources.onReady(init);

  resources.load(["img/bg.png", "img/grassCenter.png", "img/grassMid.png", "img/bird.png"]);

}).call(this);
