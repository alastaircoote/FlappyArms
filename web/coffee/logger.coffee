define ["libs/microevent"], (MicroEvent) ->
    class Logger extends MicroEvent
        constructor: () ->

        log: (level,msg) ->
            console.log "#{level}: #{msg}"
            @trigger level, msg

        info: (msg) ->
            @log "info", msg

        error: (msg) ->
            @log "error", msg

    return new Logger()