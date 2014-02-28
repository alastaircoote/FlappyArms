(function() {
  window.Sprite = (function() {
    function Sprite(url, x, y, width, height, speed, frames, dir, once) {
      this.url = url;
      this.speed = speed;
      this.frames = frames;
      this.dir = dir;
      this.once = once;
      this.pos = {
        x: x,
        y: y
      };
      this._index = 0;
      this._ticks = 0;
    }

    Sprite.prototype.update = function() {
      this._index += this.speed * this._ticks;
      this.done = false;
      return this.size = {
        width: width,
        height: height
      };
    };

    Sprite.prototype.draw = function(context) {
      var frame, idx, max, x, y;
      if (this.speed > 0) {
        max = this.frames.length;
        idx = Math.floor(this._index);
        frame = this.frame[idx % max];
        if (this.once && idx >= max) {
          this.done = true;
          return;
        }
      } else {
        frame = 0;
      }
      x = pos.x;
      y = pos.y;
      if (this.dir === 'vertical') {
        y += frame * this.size.height;
      } else {
        x += fram * this.size.width;
      }
      return context.drawImage(resources.get(this.url), x, y, this.size.width, this.size.height, 0, 0, this.size.width, this.size.height);
    };

    return Sprite;

  })();

}).call(this);
