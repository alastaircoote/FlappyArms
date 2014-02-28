class window.Bird extends Entity
  constructor: (game)->
    super
    @yAccel = 0
    @VELOCITY_CHANGE_FACTOR = 0.2
    @ACCEL_CHANGE_FACTOR = 1
    @keyAlreadyDown = false
    @MIN_Y_ACCEL = -3
    @MAX_Y_ACCEL = 0.2
    @score = 0
    @img = resources.get "img/bird.png"
    @width = 28
    @height = 22
    @game = game

    @reset()
  
  update: ->
    super
    #if @y<0
    #  @game.gameOver true, @score
    #  @reset()
    if @game.obstacles.intersect(this) or @game.ground.intersect (this)
      @game.gameOver true, @score
      @reset()

    if @game.keyPressed.space and @game.keyPressed.space.keydown and not @keyAlreadyDown
      @yAccel = @MIN_Y_ACCEL
      @yVelocity = 0
      @keyAlreadyDown = true

    if @game.keyPressed.space and @game.keyPressed.space.keyup
      @keyAlreadyDown  = false

    @yVelocity += @yAccel

    @yAccel = Math.min(@yAccel+@ACCEL_CHANGE_FACTOR,@MAX_Y_ACCEL) if @yAccel < @MAX_Y_ACCEL
    
    if @game.obstacles.hasScorred(this)
      @score+=1

  draw: (context) ->

    context.drawImage @img,0,0,@img.width,@img.height,@x,@y,@width,@height

  reset: ->
    @x = 110
    @y = @game.height / 2-@height/2

    @yAccel = -2
    @yVelocity = 0
    @score = 0

    @game.obstacles.reset()


