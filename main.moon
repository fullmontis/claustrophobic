generate = require "generate"
sprite = require "sprite"
globals = require "globals"

{:PPS,:SIZE} = globals
{:Rect,:Room,:Layer,:Sprite} = sprite
{:generate_level,:generate_doors,:get_level,:draw_level} = generate
{:graphics} = love


scrw = graphics.getWidth!
scrh = graphics.getHeight!
        
absx = scrw/2
absy = scrh/2 + 100
mouseoldx = 0
hero = {}
hero.x,hero.y,hero.angle = 120,120,0
hero.speed = 200
hero.absx = absx
hero.absy = absy
t1 = 0
currentroom = 1
currentlayer = 1

love.load = ->

    rects,grid = generate_level(SIZE,4,3,5325)
    doors = generate_doors(rects,SIZE)    
    export layer = Layer(rects,doors,10,5,PPS)  
    layer\initialize(hero.x,hero.y)
    export heroSprite = Sprite("hero.png",absx,absy,0,true,0.5,0.5)
    

p = true
        
love.update = (dt) ->
    layer\update(hero.x,hero.y)
    mousex = love.mouse\getX!
    hero.angle += (mousex-mouseoldx)/200
    mouseoldx = mousex
    
    xnew,ynew = 0,0
    if love.keyboard.isDown "d"
        xnew += hero.speed*dt*math.cos(hero.angle)        
        ynew += hero.speed*dt*math.sin(hero.angle)
    if love.keyboard.isDown "a"
        xnew -= hero.speed*dt*math.cos(hero.angle)        
        ynew -= hero.speed*dt*math.sin(hero.angle)
    if love.keyboard.isDown "s"
        xnew -= hero.speed*dt*math.sin(hero.angle)        
        ynew += hero.speed*dt*math.cos(hero.angle)
    if love.keyboard.isDown "w"
        xnew += hero.speed*dt*math.sin(hero.angle)        
        ynew -= hero.speed*dt*math.cos(hero.angle)
    
    if layer\isInsideActive(hero.x+xnew,hero.y)
        hero.x += xnew
    
    if layer\isInsideActive(hero.x,hero.y+ynew)
        hero.y += ynew
    
    
love.draw = ->
    graphics.print love.timer.getFPS!,10,10
    graphics.print t1,10,25    
    
    -- Draws the level
    graphics.push!
    graphics.translate(absx,absy)
    graphics.rotate(-hero.angle)
    graphics.translate(-hero.x,-hero.y)
    layer\draw!
    graphics.pop!
    
    -- Draws the player
    heroSprite\draw!
    
 
