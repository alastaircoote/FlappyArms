(function() {
  requirejs({
    paths: {
      jquery: "//code.jquery.com/jquery-1.11.0.min",
      socket: "//actuallyflaptho.alastair.is/socket.io/socket.io"
    },
    shim: {
      "game/main": {
        deps: ["jquery", "libs/jquery.transit.min", "game/buzz.min"]
      },
      "game/buzz.min": {
        exports: "buzz"
      }
    }
  });

  require(['tap-client', 'tap-server'], function(Client, Server) {
    console.log(Modernizr.touch);
    if (/(iPad|iPod|iPhone)/.test(window.navigator.userAgent)) {
      $("body").addClass("ipad");
      $("body").css("height", "672px");
      new Server();
      return;
    }
    if (Modernizr.touch && window.location.search.indexOf("server=1") === -1) {
      return new Client();
    } else {
      return new Server();
    }
  });

}).call(this);
