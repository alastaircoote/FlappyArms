(function(){var e=function(e,t){return function(){return e.apply(t,arguments)}},t={}.hasOwnProperty,n=function(e,n){function r(){this.constructor=e}for(var o in n)t.call(n,o)&&(e[o]=n[o]);return r.prototype=n.prototype,e.prototype=new r,e.__super__=n.prototype,e};define(["comm-layer","servers","logger"],function(t,r,o){var i;return i=function(t){function i(){this.webRTCConnected=e(this.webRTCConnected,this),this.receive=e(this.receive,this),this.connect=e(this.connect,this),this.on("socketio-connected",function(e){return function(){return e.socket.emit("is-host")}}(this)),this.on("webrtc-connected",this.webRTCConnected),this.on("receive",this.receive),i.__super__.constructor.call(this)}return n(i,t),i.prototype.connect=function(){return this.serverIndex=Math.floor(Math.random()*r.socketio.length),o.info("Chose to connect to server #"+this.serverIndex),this.connectSocketIO(this.serverIndex)},i.prototype.receive=function(e){return"receive-id"===e.ev?(o.info("Received socket.io ID "+e.id+" from server #"+this.serverIndex),this.trigger("id-received",String(this.serverIndex+1)+e.id)):void 0},i.prototype.webRTCConnected=function(e){return o.info("Sending WebRTC peer ID "+e+" to socket.io server..."),this.socket.emit("attach-peerid",e)},i}(t)})}).call(this);