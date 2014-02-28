

class window.Grass extends Entity
  constructor: (game) ->
    super
    @game = game
    @pattern = null

    @width = @game.width
    @height = 10
    @y = @game.height - @height

  update: ->
    

  draw: (context) ->
    if not @pattern
      @pattern = @getPattern context

    context.fillStyle = @pattern
    context.save()
    context.translate @x,@y
    context.fillRect 0,0,@width,@height
    context.restore()

  getPattern: (context) ->
    tile = resources.get "img/grassMid.png"
    context.createPattern tile,"repeat"



