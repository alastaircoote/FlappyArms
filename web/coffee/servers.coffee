define () ->
    return {
        socketio: [
           #'http://actuallyflaptho.alastair.is:80'
           'http://sock.flappyarms.sexy:80/flappyarms'
        ]
        webrtc: [
            {host:'peer.flappyarms.sexy', port:80}
            #'actuallyflaptho.alastair.is'
        ]
    }