(function() {
  define(["libs/gyro"], function(gyro) {
    var avg, isOn, lastFive, lastFlap, maxZ, minZ, old;
    isOn = false;
    old = null;
    gyro.frequency = 10;
    lastFive = [];
    avg = function(arr) {
      var i, t, _i, _len;
      t = 0;
      for (_i = 0, _len = arr.length; _i < _len; _i++) {
        i = arr[_i];
        t += i;
      }
      return t / arr.length;
    };
    maxZ = 0;
    minZ = 0;
    lastFlap = 0;
    document.ontouchstart = function(e) {
      console.log(e.target);
      e.stopPropagation();
      if (e.target === document.body) {
        e.preventDefault();
      }
      if (e.touches.length > 1) {
        return;
      }
      console.log("touchstart");
      maxZ = 0;
      minZ = 0;
      return gyro.startTracking(function(o) {
        var avgVals, rounded;
        lastFive.push(o);
        avgVals = {
          x: avg(lastFive.map(function(o) {
            return o.x;
          })),
          y: avg(lastFive.map(function(o) {
            return o.y;
          })),
          z: avg(lastFive.map(function(o) {
            return o.z;
          }))
        };
        lastFive = [];
        rounded = {
          x: Math.round(avgVals.x),
          y: Math.round(avgVals.y),
          z: Math.round(avgVals.z)
        };
        rounded = {
          x: Math.round(o.x),
          y: Math.round(o.y),
          z: Math.round(o.z)
        };
        console.log(rounded.z);
        old = rounded;
        if (rounded.z < minZ) {
          minZ = rounded.z;
        }
        if (rounded.z > maxZ) {
          maxZ = rounded.z;
        }
        if (rounded.z >= -minZ) {
          if (minZ < -3) {
            if (Date.now() - lastFlap < 200) {
              return;
            }
            lastFlap = Date.now();
            console.log("flapperated");
            $("body").trigger("flap");
            if (navigator.vibrate) {
              navigator.vibrate(100);
            }
          }
          maxZ = 0;
          return minZ = 0;
        }
      });
    };
    return document.ontouchend = function() {
      console.log("end");
      return gyro.stopTracking();
    };
  });

}).call(this);
