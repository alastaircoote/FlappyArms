(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["servers", "socket", "game/main"], function(servers, io, Birdie) {
    var Server;
    return Server = (function() {
      function Server() {
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
      }

      Server.prototype.gotClient = function() {
        $("#intro").hide();
        return $("#howtoplay").show();
      };

      Server.prototype.receiveId = function(data) {
        this.socketId = data;
        return $("#numbers").html(String(this.key + 1) + data);
      };

      Server.prototype.receive = function(data) {
        if (data.ev === "toucherated") {
          return this.flap(data);
        }
      };

      Server.prototype.flap = function(data) {
        console.log("flap!");
        this.flapsSoFar++;
        if (this.flapsSoFar === 1) {
          return $("#signal1").addClass("active");
        } else if (this.flapsSoFar === 2) {
          return $("#signal2").addClass("active");
        } else if (this.flapsSoFar === 3) {
          return $("#signal3").addClass("active");
        } else {
          if (this.flapsSoFar === 4) {
            $("#instruction-box").css("opacity", 0);
          }
          return $("body").trigger("flap");
        }
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
