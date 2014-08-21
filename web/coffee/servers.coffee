define () ->
    return {
        socketio: [
           'http://' + window.location.hostname + ':5010/flappyarms'
           'http://sock.flappyarms.sexy:80/flappyarms'
        ]
        webrtc: [
            {host:window.location.hostname, port:5011}
            {host:'peer.flappyarms.sexy', port:80}
        ]
    }