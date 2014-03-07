(function(){var t=function(t,e){return function(){return t.apply(e,arguments)}};define(["jquery","game/main","host-comm","logger"],function(e,i,o,n){var s;return s=function(){function s(){this.disconnected=t(this.disconnected,this),this.gameover=t(this.gameover,this),this.flap=t(this.flap,this),this.receive=t(this.receive,this),this.receiveId=t(this.receiveId,this),this.gotClient=t(this.gotClient,this),this.comm=new o,this.comm.connect(),this.comm.on("id-received",this.receiveId),this.comm.on("receive",this.receive),this.comm.on("disconnected",this.disconnected),this.comm.on("ping",function(){}),e("#gamecontainer, #instruction-box").css("display","block"),i(),this.flapsSoFar=0,e("body").on("gameStarted",function(){return e("#bigscore").show(),e("#instruction-box").hide(),e("#howtoplay, #intro, h1").hide()}),e("body").on("gameover",this.gameover),n.on("info",function(t){return e("#infobox").append(e("<p/>").html(t)),e("#infobox").scrollTop(99999)}),e("#infobutton").on("click",function(){return e("#infobox").toggle()})}return s.prototype.gotClient=function(){return"block"!==e("#gameover").css("display")?(e("#intro").hide(),e("#howtoplay, #signals").show()):void 0},s.prototype.receiveId=function(t){return this.socketId=t,e("#numbers").html(t)},s.prototype.receive=function(t){return"toucherated"===t.ev&&this.flap(t),"client-attached"===t.ev?this.gotClient():void 0},s.prototype.flap=function(){var t,i;return this.flapsSoFar++,t=new Date,i=t.getHours()+":"+t.getMinutes()+":"+t.getSeconds()+":"+t.getMilliseconds(),n.info("Received message at "+i),1===this.flapsSoFar?e("#signal1").addClass("active"):2===this.flapsSoFar?e("#signal2").addClass("active"):3===this.flapsSoFar?e("#signal3").addClass("active"):e("body").trigger("flap")},s.prototype.gameover=function(t,i){return e("#bigscore").hide(),e("#score").html(i),e("#gameover, #signals").show(),e("#signals .signal.active").removeClass("active"),e("#instruction-box").show(),this.flapsSoFar=0},s.prototype.disconnected=function(){return e("#numbers").html(""),this.socketId=null,e("#intro, #instruction-box, h1").show(),e("#howtoplay, #signals, #gameover").hide(),e("body").trigger("resetgame"),this.comm.connect()},s}()})}).call(this);