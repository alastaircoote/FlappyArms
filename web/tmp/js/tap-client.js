(function() {
  comm.client = function() {
    var button, socket, tb;
    $("body").addClass("client");
    tb = $("<input type='number'/>");
    button = $("<button>Enter</button>");
    socket = io.connect('http://actuallyflaptho.alastair.is:80');
    tb.on("keydown", function(e) {
      console.log(e);
      e.preventDefault();
      return e.stopPropagation();
    });
    $("body").append(tb, button);
    socket.on("attached", function() {
      return console.log("attached");
    });
    button.on("touchstart", function(e) {
      return e.stopPropagation();
    });
    button.on("click", function(e) {
      console.log("hi");
      e.preventDefault();
      return socket.emit("attach-to-id", {
        code: "11"
      });
    });
    return socket.on("got-host", function(data) {
      return $("body").on("flap", function() {
        console.log("touched");
        return socket.emit("send", {
          ev: "toucherated",
          time: Date.now()
        });
      });
    });
  };

}).call(this);
