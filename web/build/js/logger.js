(function(){var t={}.hasOwnProperty,o=function(o,r){function n(){this.constructor=o}for(var e in r)t.call(r,e)&&(o[e]=r[e]);return n.prototype=r.prototype,o.prototype=new n,o.__super__=r.prototype,o};define(["libs/microevent"],function(t){var r;return new(r=function(t){function r(){}return o(r,t),r.prototype.log=function(t,o){return console.log(""+t+": "+o),this.trigger(t,o)},r.prototype.info=function(t){return this.log("info",t)},r.prototype.error=function(t){return this.log("error",t)},r}(t))})}).call(this);