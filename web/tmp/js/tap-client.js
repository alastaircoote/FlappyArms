(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["jquery", "flap", "servers", "client-comm"], function($, flap, servers, ClientCommLayer) {
    var Client;
    return Client = (function() {
      Client.prototype.isIos = (function() {
        return /(iPad|iPod|iPhone)/.test(window.navigator.userAgent);
      })();

      function Client() {
        this.gotHost = __bind(this.gotHost, this);
        this.keypressed = __bind(this.keypressed, this);
        this.keydowned = __bind(this.keydowned, this);
        this.receive = __bind(this.receive, this);
        this.connect = __bind(this.connect, this);
        $("body").addClass("client");
        this.connectForm = $("#clientsub");
        this.commLayer = new ClientCommLayer();
        this.connectForm.on("submit", this.connect);
        if (this.isIos) {
          $('#codenum').on("keydown", this.keydowned);
          $("#codenum").on('focus', (function(_this) {
            return function() {
              _this.currentNum = "";
              return $('#nums').html("");
            };
          })(this));
        }
        this.currentNum = "";
        flap();
        $("body").on("flap", (function(_this) {
          return function() {
            console.log("touched");
            if (_this.connected) {
              return _this.socket.emit("send", {
                ev: "toucherated",
                time: Date.now()
              });
            } else {
              return console.log("Flap while not connected.");
            }
          };
        })(this));
        $(window).on("scroll", function() {
          return $(window).scrollTop(0);
        });
      }

      Client.prototype.connect = function(e) {
        var key, val;
        console.log("do connect");
        e.preventDefault();
        val = $('#codenum').val();
        if (this.isIos) {
          val = this.currentNum;
        }
        this.commLayer.connect(val);
        return;
        key = parseInt(val.substr(0, 1), 10);
        console.log(key, val.substr(1));
        if (!servers.socketio[key - 1]) {
          return this.noHost();
        }
        this.socket = io.connect(servers.socketio[key - 1]);
        console.log("connecting");
        this.socket.on("connect", (function(_this) {
          return function() {
            _this.connected = true;
            console.log("connected");
            return _this.socket.emit("is-client", {
              code: val.substr(1)
            });
          };
        })(this));
        this.socket.on("disconnect", (function(_this) {
          return function() {
            console.log("disconnected");
            return _this.connected = false;
          };
        })(this));
        return this.socket.on("receive", this.receive);
      };

      Client.prototype.receive = function(data) {
        console.log(data);
        if (data.ev === "host-attached") {
          return this.gotHost();
        }
        if (data.ev === "host-disconnected") {
          $("#client_intro").show();
          $('#client_play').hide();
          $("body").removeClass("doflap touched");
          this.socket.disconnect();
        }
        if (data.ev === "no-host") {
          this.noHost();
          return this.socket.disconnect();
        }
      };

      Client.prototype.noHost = function() {
        return alert("Sorry, we couldn't find a partner with that ID. Try reloading both browsers.");
      };

      Client.prototype.keydowned = function(e) {
        e.preventDefault();
        e.stopPropagation();
        if (e.keyCode === 8) {
          this.currentNum = this.currentNum.substr(0, this.currentNum.length - 1);
        } else if (e.keyCode >= 48 && e.keyCode <= 57) {
          this.currentNum += String.fromCharCode(e.keyCode);
        }
        return $('#nums').html(this.currentNum);
      };

      Client.prototype.keypressed = function(e) {
        console.log(e, typeof e.keyCode);
        e.preventDefault();
        e.stopPropagation();
        if ([53, 8].indexOf(e.keyCode) > -1) {
          this.currentNum = this.currentNum.substr(0, this.currentNum.length - 2);
        } else if (e.keyCode >= 48 && e.keyCode <= 57) {
          this.currentNum += String.fromCharCode(e.keyCode);
        }
        return $('#nums').html(this.currentNum);
      };

      Client.prototype.gotHost = function() {
        $("#client_intro").hide();
        $('#client_play').show();
        $("body").addClass("doflap");
        return console.log("got host", arguments);
      };

      return Client;

    })();
  });

}).call(this);
