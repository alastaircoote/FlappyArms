(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["libs/peer", "libs/socketio", "servers", "libs/microevent", "logger"], function(Peer, io, servers, MicroEvent, Logger) {
    var CommLayer;
    return CommLayer = (function(_super) {
      __extends(CommLayer, _super);

      CommLayer.prototype.SupportsWebRTC = util.supports.data;

      function CommLayer() {
        this.disconnect = __bind(this.disconnect, this);
        this.send = __bind(this.send, this);
        this.receiveSocket = __bind(this.receiveSocket, this);
        this.connectWebRTC = __bind(this.connectWebRTC, this);
        this.connectSocketIO = __bind(this.connectSocketIO, this);
      }

      CommLayer.prototype.connectSocketIO = function(idx) {
        var targetServer;
        this.serverIndex = idx;
        targetServer = servers.socketio[idx];
        if (!targetServer) {
          alert("No");
        }
        Logger.info("Mapped socket.io server index " + idx + " to " + targetServer);
        if (!this.socket) {
          this.socket = io.connect(targetServer);
          this.socket.on("receive", (function(_this) {
            return function(data) {
              return _this.receiveSocket(data);
            };
          })(this));
          return this.socket.on("connect", (function(_this) {
            return function() {
              Logger.info("Connected to socket.io server");
              _this.trigger("socketio-connected");
              return _this.connectWebRTC();
            };
          })(this));
        } else {
          return this.trigger("socketio-connected");
        }
      };

      CommLayer.prototype.connectWebRTC = function(id) {
        if (!this.SupportsWebRTC) {
          return Logger.info("Browser does not support WebRTC data :(");
        }
        this.peer = new Peer({
          host: servers.webrtc[this.serverIndex],
          port: 5001,
          path: "/"
        });
        this.peer.on("connection", this.webRTCConnectionEstablished);
        Logger.info("Browser supports WebRTC data, connecting to server...");
        return this.peer.on("open", (function(_this) {
          return function(id) {
            Logger.info("Received WebRTC PeerId " + id + ".");
            return _this.trigger("webrtc-connected", id);
          };
        })(this));
      };

      CommLayer.prototype.receiveSocket = function(data) {
        if (data.ev === "host-attached" && this.SupportsWebRTC) {
          Logger.info("Attempting to connect via WebRTC...");
          this.peerConnection = this.peer.connect(data.peerId);
          this.peerConnection.on("open", function() {
            Logger.info("Successfully established WebRTC connection");
            this.peerConnection.on("receive", (function(_this) {
              return function(data) {
                return _this.trigger("receive", data);
              };
            })(this));
            return this.useWebRTC = true;
          });
          return;
        }
        return this.trigger("receive", data);
      };

      CommLayer.prototype.send = function(data) {
        if (this.useWebRTC) {
          Logger.info("Sending via webRTC");
          return this.peerConnection.send("receive", data);
        } else {
          return this.socket.emit("send", data);
        }
      };

      CommLayer.prototype.webRTCConnectionEstablished = function(peerConnection) {
        this.peerConnection = peerConnection;
        Logger.info("Successfully established WebRTC connection with client.");
        this.peerConnection.on("receive", (function(_this) {
          return function(data) {
            return _this.trigger("receive", data);
          };
        })(this));
        return this.useWebRTC = true;
      };

      CommLayer.prototype.disconnect = function() {
        Logger.info("Closing connections...");
        this.socket.disconnect();
        return this.peer.destroy();
      };

      return CommLayer;

    })(MicroEvent);
  });

}).call(this);
