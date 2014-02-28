(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Grass = (function(_super) {
    __extends(Grass, _super);

    function Grass(game) {
      Grass.__super__.constructor.apply(this, arguments);
      this.game = game;
      this.pattern = null;
      this.width = this.game.width;
      this.height = 10;
      this.y = this.game.height - this.height;
    }

    Grass.prototype.update = function() {};

    Grass.prototype.draw = function(context) {
      if (!this.pattern) {
        this.pattern = this.getPattern(context);
      }
      context.fillStyle = this.pattern;
      context.save();
      context.translate(this.x, this.y);
      context.fillRect(0, 0, this.width, this.height);
      return context.restore();
    };

    Grass.prototype.getPattern = function(context) {
      var tile;
      tile = resources.get("img/grassMid.png");
      return context.createPattern(tile, "repeat");
    };

    return Grass;

  })(Entity);

}).call(this);
