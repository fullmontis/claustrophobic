sprite = {}

{:graphics} = love

is_near = (rect1,rect2) ->
    if rect1.x == rect2.x+rect2.w or rect2.x == rect1.x+rect1.w or rect1.y == rect2.y+rect2.h or rect2.y == rect1.y+rect1.h
        return true
    return false   

class Rect
    new: (x,y,w,h,id=0,color={255,255,255}) =>
        @x = x
        @y = y
        @w = w
        @h = h
        @id = id
        @color = color
        
-- this is the main class of the level        
class Layer
    new: (rooms,doors,border,wall,PPS) =>

        --  puts all the rects with the same id in the same rooms[i]
        @rooms = {}
        for _,rect in pairs(rooms)
            if not @rooms[rect.id]
                @rooms[rect.id] = {}
            @rooms[rect.id][#@rooms[rect.id]+1] = Rect(rect.x*PPS,rect.y*PPS,rect.w*PPS,rect.h*PPS,rect.id)
            
        -- creates rectangles that work as doors and adds them to the corresponding rooms
        -- there are actually two copies of each door, one for every room, to avoid more parsing
        doorw = 70
        doorh = 70
        for _,door in pairs(doors)
            @rooms[door[3]][#@rooms[door[3]]+1] = Rect(door[1]*PPS-doorw/2,door[2]*PPS-doorh/2,doorw,doorh,door[3])
            @rooms[door[4]][#@rooms[door[4]]+1] = Rect(door[1]*PPS-doorw/2,door[2]*PPS-doorh/2,doorw,doorh,door[4])  
        
        -- in this table we collect in roomsnear[i] the ids of the rooms near the room with id i
        -- this also contains the same room
        -- this is required to avoid a lot of parsing on the whole lot of rooms on runtime and save a lot of frames
        @roomsnear = {}
        for id1=1,#@rooms
            @roomsnear[id1] = {}
            @roomsnear[id1][id1] = id1
            for _,rect1 in pairs(@rooms[id1])
                for id2=1,#@rooms
                    for _,rect2 in pairs(@rooms[id2])   
                        if is_near(rect1,rect2) 
                            @roomsnear[id1][id2] = id2
                
        @active = {}
        @border = border
        @wall = wall
        
    initialize: (x,y) =>
        @active = {}
        for _,room in pairs(@rooms)
            for _,rect in pairs(room)
                if @isInsideId(x,y,rect.id)
                    @active[rect.id] = rect.id
                    print rect.id

    draw: =>
        for _,active in pairs(@active)
            for _,rect in pairs(@rooms[active])
                graphics.rectangle "fill",rect.x+@wall,rect.y+@wall,rect.w-2*@wall,rect.h-2*@wall
                
    -- returns true if we are inside a room with assigned id
    isInsideId: (x,y,id) =>  
        for _,rect in pairs(@rooms[id])
            if x>=rect.x+@border and x<=rect.x+rect.w-@border and y>=rect.y+@border and y<=rect.y+rect.h-@border
                return true
        return false   
        
    -- returns true if the coordinates are inside one of the active rooms 
    isInsideActive: (x,y) =>
        for _,active in pairs(@active)
            if @isInsideId(x,y,active)
                return true
        return false  
      
    update: (x,y) =>
        c = @active
        @active = {}
        for _,active in pairs(c)
            for _,id in pairs(@roomsnear[active])
                if @isInsideId(x,y,id)
                    @active[id] = id

                

        

    
    
class Sprite
    new: (path, x,y,angle, visible=true, anchorx=0, anchory=0) =>
        @image = graphics.newImage path
        @x = x
        @y = y
        @angle = angle
        @visible = visible
        @w = @image\getWidth!
        @h = @image\getHeight!
        @anchor.x = anchorx
        @anchor.y = anchory
    anchor:
        x: 0
        y: 0
    draw: => 
        if @visible
            graphics.push!
            graphics.translate @x, @y 
            graphics.rotate @angle
            graphics.draw @image, -@anchor.x*@w, -@anchor.y*@h
            graphics.pop!
            
sprite.Rect = Rect
sprite.Layer = Layer
sprite.Sprite = Sprite
sprite.is_near = is_near
return sprite