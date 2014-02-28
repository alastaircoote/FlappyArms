(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Entity = (function() {
    function Entity() {
      this.x = 0;
      this.y = 0;
      this.width = 0;
      this.height = 0;
      this.xVelocity = 0;
      this.yVelocity = 0;
      this.game = null;
    }

    Entity.prototype.update = function() {
      this.x += this.xVelocity;
      return this.y += this.yVelocity;
    };

    Entity.prototype.draw = function(context) {
      context.fillStyle = '#fff';
      return context.fillRect(this.x, this.y, this.width, this.height);
    };

    Entity.prototype.intersect = function(other) {
      return this.y + this.height > other.y && this.y < other.y + other.height && this.x + this.width > other.x && this.x < other.x + other.width;
    };

    return Entity;

  })();

  window.Background = (function(_super) {
    __extends(Background, _super);

    function Background(game) {
      Background.__super__.constructor.apply(this, arguments);
      this.game = game;
      this.width = this.game.width;
      this.height = this.game.height;
      this.pattern = null;
    }

    Background.prototype.draw = function(context) {
      var backgroundTile;
      if (!this.pattern) {
        backgroundTile = resources.get("img/bg.png");
        this.pattern = context.createPattern(backgroundTile, "repeat");
      }
      context.fillStyle = this.pattern;
      context.fill();
      return context.fillRect(this.x, this.y, this.width, this.height);
    };

    return Background;

  })(Entity);

  window.Score = (function(_super) {
    __extends(Score, _super);

    function Score(game) {
      Score.__super__.constructor.apply(this, arguments);
      this.game = game;
    }

    Score.prototype.draw = function(context) {
      context.fillStyle = '#f00';
      context.font = '40px monospace';
      return context.fillText(this.game.bird.score, this.game.width / 2 - 25, 50);
    };

    return Score;

  })(Entity);

}).call(this);
