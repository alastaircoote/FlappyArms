define () ->
    return {
        socketio: [
           #'http://actuallyflaptho.alastair.is:80'
           'http://localhost:5000/flappyarms'
        ]
        webrtc: [
            'localhost'
            #'actuallyflaptho.alastair.is'
        ]
    }