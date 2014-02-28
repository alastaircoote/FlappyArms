class window.Obstacle extends Entity
  constructor: (game,x,y,height) ->
    super
    @width = 60
    @height = height
    @game = game
    @x = x
    @y = y
    @xVelocity = -3
    @pattern = null

  isOutOfView: ->
    @x+@width <= 0

  draw: (context) ->
    if not @pattern
      @pattern = @getPatten context

    context.fillStyle = @pattern
    context.save()
    context.translate @x,@y
    context.fillRect 0,0,@width,@height
    context.restore()

  getPatten: (context) ->
      tile = resources.get "img/grassCenter.png"
      context.createPattern tile,"repeat"




class window.Obstacles extends Entity
  constructor: (game) ->
    super
    @OBSTACLE_DISTANCE_X = game.width * 0.6
    @OBSTACLE_GAP_Y = 205
    @game = game
    @obstacles= []

  update: ->

    for obstacle in @obstacles
      obstacle.top.update()
      obstacle.bottom.update()

    toBeRemoved = @obstacles.filter (o) ->
      o.top.isOutOfView()

    for o in toBeRemoved
      @obstacles.splice @obstacles.indexOf(o),1

    if @shouldCreateObstacle()
      obstacle = {top:null, bottom:null, hasPassed:false}
      obstacle.top = new Obstacle @game, @game.width, 0, @generateHeight()

      heightBottom = obstacle.top.height+@OBSTACLE_GAP_Y
      obstacle.bottom = new Obstacle @game, @game.width, heightBottom, @game.height - heightBottom

      @obstacles.push obstacle


  reset: ->
    @obstacles = []

  generateHeight: ->
    min = 20
    max = @game.height - 300
    Math.floor(Math.random() * (max - min + 1) + min)

  draw: (context) ->
    super
    for obstacle in @obstacles
      obstacle.top.draw context
      obstacle.bottom.draw context

  intersect: (other) ->
    for obstacle in @obstacles
      if obstacle.top.intersect(other) or obstacle.bottom.intersect(other)
        return true

    return false

  hasScored: (other) ->
    for obstacle in @obstacles
      return false

  shouldCreateObstacle: ->
    @obstacles.length == 0 ||
    @obstacles[@obstacles.length-1].top.x + @OBSTACLE_DISTANCE_X < @game.width

  hasScorred: (other)->
    obstacle = _.find @obstacles,(o) ->
      o.hasPassed == false
    if obstacle and obstacle.top.x < other.x+other.width
      obstacle.hasPassed = true
      return true
    return false
