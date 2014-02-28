(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Obstacle = (function(_super) {
    __extends(Obstacle, _super);

    function Obstacle(game, x, y, height) {
      Obstacle.__super__.constructor.apply(this, arguments);
      this.width = 60;
      this.height = height;
      this.game = game;
      this.x = x;
      this.y = y;
      this.xVelocity = -3;
      this.pattern = null;
    }

    Obstacle.prototype.isOutOfView = function() {
      return this.x + this.width <= 0;
    };

    Obstacle.prototype.draw = function(context) {
      if (!this.pattern) {
        this.pattern = this.getPatten(context);
      }
      context.fillStyle = this.pattern;
      context.save();
      context.translate(this.x, this.y);
      context.fillRect(0, 0, this.width, this.height);
      return context.restore();
    };

    Obstacle.prototype.getPatten = function(context) {
      var tile;
      tile = resources.get("img/grassCenter.png");
      return context.createPattern(tile, "repeat");
    };

    return Obstacle;

  })(Entity);

  window.Obstacles = (function(_super) {
    __extends(Obstacles, _super);

    function Obstacles(game) {
      Obstacles.__super__.constructor.apply(this, arguments);
      this.OBSTACLE_DISTANCE_X = game.width * 0.6;
      this.OBSTACLE_GAP_Y = 205;
      this.game = game;
      this.obstacles = [];
    }

    Obstacles.prototype.update = function() {
      var heightBottom, o, obstacle, toBeRemoved, _i, _j, _len, _len1, _ref;
      _ref = this.obstacles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        obstacle = _ref[_i];
        obstacle.top.update();
        obstacle.bottom.update();
      }
      toBeRemoved = this.obstacles.filter(function(o) {
        return o.top.isOutOfView();
      });
      for (_j = 0, _len1 = toBeRemoved.length; _j < _len1; _j++) {
        o = toBeRemoved[_j];
        this.obstacles.splice(this.obstacles.indexOf(o), 1);
      }
      if (this.shouldCreateObstacle()) {
        obstacle = {
          top: null,
          bottom: null,
          hasPassed: false
        };
        obstacle.top = new Obstacle(this.game, this.game.width, 0, this.generateHeight());
        heightBottom = obstacle.top.height + this.OBSTACLE_GAP_Y;
        obstacle.bottom = new Obstacle(this.game, this.game.width, heightBottom, this.game.height - heightBottom);
        return this.obstacles.push(obstacle);
      }
    };

    Obstacles.prototype.reset = function() {
      return this.obstacles = [];
    };

    Obstacles.prototype.generateHeight = function() {
      var max, min;
      min = 20;
      max = this.game.height - 300;
      return Math.floor(Math.random() * (max - min + 1) + min);
    };

    Obstacles.prototype.draw = function(context) {
      var obstacle, _i, _len, _ref, _results;
      Obstacles.__super__.draw.apply(this, arguments);
      _ref = this.obstacles;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        obstacle = _ref[_i];
        obstacle.top.draw(context);
        _results.push(obstacle.bottom.draw(context));
      }
      return _results;
    };

    Obstacles.prototype.intersect = function(other) {
      var obstacle, _i, _len, _ref;
      _ref = this.obstacles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        obstacle = _ref[_i];
        if (obstacle.top.intersect(other) || obstacle.bottom.intersect(other)) {
          return true;
        }
      }
      return false;
    };

    Obstacles.prototype.hasScored = function(other) {
      var obstacle, _i, _len, _ref;
      _ref = this.obstacles;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        obstacle = _ref[_i];
        return false;
      }
    };

    Obstacles.prototype.shouldCreateObstacle = function() {
      return this.obstacles.length === 0 || this.obstacles[this.obstacles.length - 1].top.x + this.OBSTACLE_DISTANCE_X < this.game.width;
    };

    Obstacles.prototype.hasScorred = function(other) {
      var obstacle;
      obstacle = _.find(this.obstacles, function(o) {
        return o.hasPassed === false;
      });
      if (obstacle && obstacle.top.x < other.x + other.width) {
        obstacle.hasPassed = true;
        return true;
      }
      return false;
    };

    return Obstacles;

  })(Entity);

}).call(this);
