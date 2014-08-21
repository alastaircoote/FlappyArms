define ["libs/microevent"], (MicroEvent) ->
    class Logger extends MicroEvent
        constructor: () ->

        log: (level,msg) ->
            #console.log "#{level}:", msg
            @trigger level, msg

        info: (msg) ->
            @log "info", arguments

        error: (msg) ->
            @log "error", arguments

    return new Logger()