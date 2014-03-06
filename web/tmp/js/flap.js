(function() {
  define(["libs/gyro"], function(gyro) {
    var avg, currentState, isOn, lastFive, lastFlap, maxZ, minZ, old;
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
    document.ontouchmove = function(e) {
      return e.preventDefault();
    };
    currentState = "";
    document.ontouchstart = function(e) {
      if (!$("body").hasClass("doflap")) {
        return;
      }
      $("body").addClass("touched");
      e.stopPropagation();
      if (e.touches.length > 1) {
        return;
      }
      maxZ = 0;
      minZ = 0;
      return gyro.startTracking(function(o) {
        var avgVals, rounded;
        lastFive.push(o);
        if (lastFive.length < 5) {
          return;
        }
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
        if (currentState === "positive" && rounded.z < 0) {
          minZ = 0;
        } else {
          currentState = rounded.z < 0 ? "negative" : "positive";
        }
        old = rounded;
        if (rounded.z < minZ) {
          minZ = rounded.z;
        }
        if (rounded.z > maxZ) {
          maxZ = rounded.z;
        }
        if (rounded.z >= -minZ && minZ < 0 && maxZ > 0) {
          console.log("maybe flap", minZ, maxZ);
          if (maxZ > 10) {
            if (Date.now() - lastFlap < 200) {
              return;
            }
            lastFlap = Date.now();
            console.log("flapperated");
            $("body").trigger("flap");
            setTimeout(function() {
              maxZ = 0;
              return minZ = 0;
            }, 1000);
            maxZ = 0;
            return minZ = 0;
          }
        }
      });
    };
    return document.ontouchend = function() {
      $("body").removeClass("touched");
      return gyro.stopTracking();
    };
  });

}).call(this);
