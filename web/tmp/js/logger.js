(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(["libs/microevent"], function(MicroEvent) {
    var Logger;
    Logger = (function(_super) {
      __extends(Logger, _super);

      function Logger() {}

      Logger.prototype.log = function(level, msg) {
        console.log("" + level + ": " + msg);
        return this.trigger(level, msg);
      };

      Logger.prototype.info = function(msg) {
        return this.log("info", msg);
      };

      Logger.prototype.error = function(msg) {
        return this.log("error", msg);
      };

      return Logger;

    })(MicroEvent);
    return new Logger();
  });

}).call(this);
