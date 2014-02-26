(function() {
  comm.client = function() {
    var button, socket, tb;
    tb = $("<input type='number'/>");
    button = $("<button>Enter</button>");
    socket = io.connect('http://10.0.1.9:5000');
    $("body").append(tb, button);
    socket.on("attached", function() {
      return console.log("attached");
    });
    button.on("click", function(e) {
      console.log("hi");
      e.preventDefault();
      return socket.emit("attach-to-id", {
        code: tb.val()
      });
    });
    return socket.on("got-host", function() {
      console.log("got host");
      return $("body").on("click", function() {
        console.log("touched");
        return socket.emit("toucherated");
      });
    });
  };

}).call(this);
