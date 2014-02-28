requirejs
    paths:
        jquery: "//code.jquery.com/jquery-1.11.0.min"
        socket: "//actuallyflaptho.alastair.is/socket.io/socket.io"

    shim:
        "game/main":
            deps: [
                "jquery"
                "libs/jquery.transit.min"
                "game/buzz.min"
            ]
        "game/buzz.min":
            exports:"buzz"


require ['tap-client', 'tap-server'], (Client,Server) ->
    console.log Modernizr.touch
    if Modernizr.touch
        new Client()
    else
        new Server()