(function() {
  comm.server = function() {
    var div, gamestarted, socket;
    div = $("<div/>");
    socket = io.connect('http://actuallyflaptho.alastair.is:80');
    socket.emit("get-id");
    socket.on("send-id", function(val) {
      return div.html("Go on your phone and enter 1" + val);
    });
    socket.on("got-client", function() {
      return console.log("got client");
    });
    gamestarted = false;
    return socket.on("receive", function(data) {
      var game;
      if (data.ev === "toucherated") {
        console.log("flapped");
        game = window.game;
        if (game.isGameOver || !gamestarted) {
          game.gameOver(false);
          if (!gamestarted) {
            game.start();
          }
          gamestarted = true;
          return;
        }
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

}).call(this);
