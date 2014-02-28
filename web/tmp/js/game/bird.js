(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Bird = (function(_super) {
    __extends(Bird, _super);

    function Bird(game) {
      Bird.__super__.constructor.apply(this, arguments);
      this.yAccel = 0;
      this.VELOCITY_CHANGE_FACTOR = 0.2;
      this.ACCEL_CHANGE_FACTOR = 1;
      this.keyAlreadyDown = false;
      this.MIN_Y_ACCEL = -3;
      this.MAX_Y_ACCEL = 0.2;
      this.score = 0;
      this.img = resources.get("img/bird.png");
      this.width = 28;
      this.height = 22;
      this.game = game;
      this.reset();
    }

    Bird.prototype.update = function() {
      Bird.__super__.update.apply(this, arguments);
      if (this.game.obstacles.intersect(this) || this.game.ground.intersect(this)) {
        this.game.gameOver(true, this.score);
        this.reset();
      }
      if (this.game.keyPressed.space && this.game.keyPressed.space.keydown && !this.keyAlreadyDown) {
        this.yAccel = this.MIN_Y_ACCEL;
        this.yVelocity = 0;
        this.keyAlreadyDown = true;
      }
      if (this.game.keyPressed.space && this.game.keyPressed.space.keyup) {
        this.keyAlreadyDown = false;
      }
      this.yVelocity += this.yAccel;
      if (this.yAccel < this.MAX_Y_ACCEL) {
        this.yAccel = Math.min(this.yAccel + this.ACCEL_CHANGE_FACTOR, this.MAX_Y_ACCEL);
      }
      if (this.game.obstacles.hasScorred(this)) {
        return this.score += 1;
      }
    };

    Bird.prototype.draw = function(context) {
      return context.drawImage(this.img, 0, 0, this.img.width, this.img.height, this.x, this.y, this.width, this.height);
    };

    Bird.prototype.reset = function() {
      this.x = 110;
      this.y = this.game.height / 2 - this.height / 2;
      this.yAccel = -2;
      this.yVelocity = 0;
      this.score = 0;
      return this.game.obstacles.reset();
    };

    return Bird;

  })(Entity);

}).call(this);
