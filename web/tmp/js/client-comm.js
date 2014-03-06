(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["comm-layer", "servers", "logger"], function(CommLayer, servers, Logger) {
    var ClientCommLayer;
    return ClientCommLayer = (function(_super) {
      __extends(ClientCommLayer, _super);

      function ClientCommLayer() {
        this.receive = __bind(this.receive, this);
        this.connect = __bind(this.connect, this);
        this.on("receive", this.receive);
        this.on("socketio-connected", (function(_this) {
          return function() {
            Logger.info("Sending pair request for #" + _this.hostId + "...");
            return _this.socket.emit("is-client", {
              code: _this.hostId
            });
          };
        })(this));
      }

      ClientCommLayer.prototype.connect = function(id) {
        this.serverIndex = parseInt(id.substr(0, 1), 10) - 1;
        this.hostId = id.substr(1);
        Logger.info("Connecting to socket.io server #" + this.serverIndex + "...");
        return this.connectSocketIO(this.serverIndex);
      };

      ClientCommLayer.prototype.receive = function(data) {
        console.log(data);
        if (data.ev === "no-host") {
          return alert("Could not find a host with that ID. Please try again - maybe reload the other device?");
        }
      };

      return ClientCommLayer;

    })(CommLayer);
  });

}).call(this);
