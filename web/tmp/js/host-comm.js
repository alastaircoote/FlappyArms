(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["comm-layer", "servers", "logger"], function(CommLayer, servers, Logger) {
    var HostCommLayer;
    return HostCommLayer = (function(_super) {
      __extends(HostCommLayer, _super);

      function HostCommLayer() {
        this.webRTCConnected = __bind(this.webRTCConnected, this);
        this.receive = __bind(this.receive, this);
        this.connect = __bind(this.connect, this);
        this.on("socketio-connected", (function(_this) {
          return function() {
            return _this.socket.emit("is-host");
          };
        })(this));
        this.on("webrtc-connected", this.webRTCConnected);
        this.on("receive", this.receive);
      }

      HostCommLayer.prototype.connect = function() {
        this.serverIndex = Math.floor(Math.random() * servers.socketio.length);
        Logger.info("Chose to connect to server #" + this.serverIndex);
        return this.connectSocketIO(this.serverIndex);
      };

      HostCommLayer.prototype.receive = function(data) {
        if (data.ev === "receive-id") {
          Logger.info("Received socket.io ID " + data.id + " from server #" + this.serverIndex);
          return this.trigger("id-received", String(this.serverIndex + 1) + data.id);
        }
      };

      HostCommLayer.prototype.webRTCConnected = function(id) {
        Logger.info("Sending WebRTC peer ID " + id + " to socket.io server...");
        return this.socket.emit("attach-peerid", id);
      };

      return HostCommLayer;

    })(CommLayer);
  });

}).call(this);
