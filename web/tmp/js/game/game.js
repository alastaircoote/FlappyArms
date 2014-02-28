(function() {
  window.Game = (function() {
    function Game(canvas) {
      var clearKeys;
      this.context = canvas.getContext("2d");
      this.width = canvas.width;
      this.height = canvas.height;
      this.keyPressed = {
        "space": {}
      };
      this.keys = {
        32: "space",
        37: "left",
        38: "up",
        39: "right",
        40: "down"
      };
      this.entities = [];
      this.isGameOver = false;
      clearKeys = (function(_this) {
        return function() {
          var keyName, keyVal, _ref, _results;
          _ref = _this.keys;
          _results = [];
          for (keyVal in _ref) {
            keyName = _ref[keyVal];
            _this.keyPressed[keyName] = {};
            _this.keyPressed[keyName]['keydown'] = false;
            _results.push(_this.keyPressed[keyName]['keyup'] = false);
          }
          return _results;
        };
      })(this);

      /*
      $(canvas).mousedown (e) =>
        @keyPressed["space"]["keydown"] = true
        @keyPressed["space"]["keyup"] = false
        e.preventDefault()
      
      $(canvas).mouseup (e) =>
        @keyPressed["space"]["keydown"] = false
        @keyPressed["space"]["keyup"] = true
        e.preventDefault()
      
      $(canvas).on "keydown keyup", (e) =>
        for keyVal, keyName of @keys
         *Clear all the array of keypressed
          @keyPressed[keyName] = {}
          @keyPressed[keyName]['keydown'] = false
          @keyPressed[keyName]['keyup'] = false
      
        keyName = @keys[e.which]
        if keyName
          @keyPressed[keyName]['keydown'] = e.type is 'keydown'
          @keyPressed[keyName]['keyup'] = e.type is 'keyup'
          e.preventDefault()
       */
    }

    Game.prototype.draw = function() {
      return this.entities.forEach((function(_this) {
        return function(entity) {
          if (entity.draw) {
            return entity.draw(_this.context);
          }
        };
      })(this));
    };

    Game.prototype.update = function() {
      return this.entities.forEach((function(_this) {
        return function(entity) {
          if (entity.update) {
            return entity.update();
          }
        };
      })(this));
    };

    Game.prototype.gameOver = function(isGameOver, score) {
      if (score == null) {
        score = 0;
      }
      this.isGameOver = isGameOver;
      if (this.isGameOver) {
        document.getElementById('game-over').style.display = "block";
        document.getElementById('game-over-overlay').style.display = "block";
        return $('#score').html(score);
      } else {
        document.getElementById('game-over').style.display = "none";
        return document.getElementById('game-over-overlay').style.display = "none";
      }
    };

    Game.prototype.start = function() {
      var fps, interval;
      fps = 60;
      interval = 1000 / fps;
      return setInterval((function(_this) {
        return function() {
          if (!_this.isGameOver) {
            _this.update();
            return _this.draw();
          }
        };
      })(this), interval);
    };

    return Game;

  })();

}).call(this);
