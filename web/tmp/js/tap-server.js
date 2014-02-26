(function() {
  comm.server = function() {
    var div, socket;
    div = $("<div/>");
    $("body").append(div);
    socket = io.connect('http://10.0.1.9:5000');
    socket.emit("get-id");
    socket.on("send-id", function(val) {
      return div.html("Go on your phone and enter 1" + val);
    });
    socket.on("got-client", function() {
      return console.log("got client");
    });
    return socket.on("touched", function() {
      return console.log("touched");
    });
  };

}).call(this);
