(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["jquery", "flap", "servers"], function($, flap, servers) {
    var Client;
    return Client = (function() {
      function Client() {
        this.gotHost = __bind(this.gotHost, this);
        this.keydowned = __bind(this.keydowned, this);
        this.connect = __bind(this.connect, this);
        $("body").addClass("client");
        this.tb = $("<input type='number'/>");
        this.button = $("<button>Enter</button>");
        this.button.on("click", this.connect);
        this.tb.on("keydown", this.keydowned);
        $("body").append(this.tb, this.button);
        console.log("sdfsd");
        flap();
      }

      Client.prototype.connect = function(e) {
        var key, val;
        console.log("stffff");
        e.preventDefault();
        val = "11";
        key = parseInt(val.substr(1), 10);
        console.log(servers[key - 1]);
        this.socket = io.connect(servers[key - 1]);
        this.socket.on("connect", (function(_this) {
          return function() {
            console.log("connected");
            return _this.socket.emit("attach-to-id", {
              code: val
            });
          };
        })(this));
        return this.socket.on("got-host", this.gotHost);
      };

      Client.prototype.keydowned = function(e) {
        console.log(e);
        e.preventDefault();
        return e.stopPropagation();
      };

      Client.prototype.gotHost = function() {
        console.log("got host");
        return $("body").on("flap", (function(_this) {
          return function() {
            console.log("touched");
            return _this.socket.emit("send", {
              ev: "toucherated",
              time: Date.now()
            });
          };
        })(this));
      };

      return Client;

    })();
  });

}).call(this);
