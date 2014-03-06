(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["servers", "socket", "game/main"], function(servers, io, Birdie) {
    var Server;
    return Server = (function() {
      function Server() {
        this.gameover = __bind(this.gameover, this);
        this.flap = __bind(this.flap, this);
        this.receive = __bind(this.receive, this);
        this.receiveId = __bind(this.receiveId, this);
        this.gotClient = __bind(this.gotClient, this);
        this.key = Math.floor(Math.random() * servers.length);
        this.socket = io.connect(servers[this.key]);
        this.socket.on("send-id", this.receiveId);
        this.socket.on("receive", this.receive);
        this.socket.on("got-client", this.gotClient);
        this.socket.emit("get-id");
        $("#gamecontainer, #instruction-box").css("display", "block");
        Birdie();
        this.flapsSoFar = 0;
        $("body").on("gameStarted", function() {
          $("#bigscore").show();
          $("#instruction-box").hide();
          return $("#howtoplay, #intro, h1").hide();
        });
        $("body").on("gameover", this.gameover);
      }

      Server.prototype.gotClient = function() {
        if ($("#gameover").css("display") === "block") {
          return;
        }
        $("#intro").hide();
        return $("#howtoplay, #signals").show();
      };

      Server.prototype.receiveId = function(data) {
        this.socketId = data;
        return $("#numbers").html(String(this.key + 1) + data);
      };

      Server.prototype.receive = function(data) {
        if (data.ev === "toucherated") {
          this.flap(data);
        }
        if (data.ev === "client-disconnected") {
          console.log("disconnect");
          return window.location.reload();
          $("#instruction-box").show();
          $("#intro").show();
          return $("#howtoplay, #signals").hide();
        }
      };

      Server.prototype.flap = function(data) {
        this.flapsSoFar++;
        if (this.flapsSoFar === 1) {
          return $("#signal1").addClass("active");
        } else if (this.flapsSoFar === 2) {
          return $("#signal2").addClass("active");
        } else if (this.flapsSoFar === 3) {
          return $("#signal3").addClass("active");
        } else {
          return $("body").trigger("flap");
        }
      };

      Server.prototype.gameover = function(e, score) {
        $("#bigscore").hide();
        $("#score").html(score);
        $("#gameover, #signals").show();
        $("#signals .signal.active").removeClass("active");
        $("#instruction-box").show();
        this.flapsSoFar = 0;
        return console.log(arguments);
      };

      return Server;

    })();
  });


  /*
  comm.server = () ->
  
      div = $("<div/>")
       *$("body").append(div)
  
      socket = io.connect('http://actuallyflaptho.alastair.is:80');
      socket.emit "get-id"
      socket.on "send-id", (val) ->
          div.html "Go on your phone and enter 1" + val
  
      socket.on "got-client", ->
          console.log "got client"
  
      gamestarted = false
      socket.on "receive", (data) ->
          if data.ev == "toucherated"
              console.log "flapped"
               *console.log Date.now() - data.time
               *console.log "touched"
              game = window.game
  
              if game.isGameOver or !gamestarted
                  game.gameOver false
                  if !gamestarted then game.start()
                  gamestarted = true
                  return
  
              game.keyPressed["space"] = {}
              game.keyPressed["space"]["keydown"] = true
              game.keyPressed["space"]["keyup"] = false
  
              setTimeout ->
                  game.keyPressed["space"] = {}
                  game.keyPressed["space"]["keydown"] = false
                  game.keyPressed["space"]["keyup"] = true
              ,20
   */

}).call(this);
