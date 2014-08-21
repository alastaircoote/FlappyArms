requirejs
    paths:
        jquery: "//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min"
        socket: "//actuallyflaptho.alastair.is/socket.io/socket.io"
        image: "libs/require-image"

    shim:
        "game/main":
            deps: [
                "jquery"
                "libs/jquery.transit.min"
                "game/buzz.min"
            ]
        "game/buzz.min":
            exports: "buzz"
        "libs/jquery.transit.min":
            deps: ["jquery"]
        "libs/socketio":
            exports: "io"
        "libs/peer":
            exports: "Peer"
        "libs/sockjs.min":
            exports: "SockJS"


require ['tap-client', 'tap-server'], (Client,Server) ->

    if /iPad/.test(window.navigator.userAgent)
        $("body").addClass("ipad")
        $("body").css "height", "672px"
        new Server()
        return
    if Modernizr.touch && window.location.search.indexOf("server=1") == -1
        new Client()
    else
        new Server()