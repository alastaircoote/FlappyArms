
class window.Sprite
  constructor: (@url,x,y,width,height,@speed,@frames, @dir, @once) ->
    @pos = {x:x,y:y}
    @_index = 0
    @_ticks = 0

  update: ->
    @_index += @speed * @_ticks
    @done = false
    @size = {width:width, height:height}

  draw: (context) ->
    if @speed > 0
      max = @frames.length
      idx = Math.floor @_index
      frame = @frame[idx % max]

      if @once && idx >= max
        @done = true
        return

    else
      frame = 0

    x = pos.x
    y = pos.y

    if @dir == 'vertical'
      y+= frame * @size.height
    else
      x+= fram * @size.width

    context.drawImage resources.get(@url), x, y, @size.width, @size.height, 0, 0, @size.width, @size.height
