(function() {
  var avg, gyro, isOn, lastFive, maxZ, minZ, old, table;

  gyro = window.returnExports;

  table = $("<table/>");

  $("body").append(table);

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

  document.ontouchstart = function() {
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
      if ((old != null ? old.z : void 0) !== rounded.z) {
        console.log(rounded);
      }
      old = rounded;
      if (rounded.z < minZ) {
        minZ = rounded.z;
      }
      if (rounded.z > maxZ) {
        maxZ = rounded.z;
      }
      if (rounded.z >= -minZ) {
        if (minZ < -3) {
          navigator.vibrate(100);
        }
        maxZ = 0;
        return minZ = 0;
      }
    });
  };

  document.ontouchend = function() {
    console.log("end");
    return gyro.stopTracking();
  };

}).call(this);
