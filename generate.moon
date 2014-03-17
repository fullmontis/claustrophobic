generate = {}

utils = require "utils"
sprite = require "sprite"
globals = require "globals"

{:Rect,:Room,:Layer,:is_near} = sprite
{:level,:trim,:norm,:toggle} = utils
{:graphics} = love
{:random,:randomseed,:floor,:pow} = math


fill_grid = (rects,size) ->  
    -- generate matrix
    grid = {} 
    for i=1,size-1
        grid[i] = {}
        for j=1,size-1
            grid[i][j] = 0
    
    for fill,rect in pairs(rects)
        for i=rect.x,rect.x+rect.w-1
            for j=rect.y,rect.y+rect.h-1
                grid[i][j] = fill
    return grid
    

generate_level = (size,avg,dev,seed) ->
    -- Fill with random rectangles
    rects = {}
    filled = 0
    randomseed(seed)
    while filled<0.6
        x,y = floor(random!*size),floor(random!*size)
        w,h = norm(avg,dev),norm(avg,dev)
        
        x = level(x,1)
        y = level(y,1)
        w = level(w,1)
        h = level(h,1)
        x = trim(x,size-w)
        y = trim(y,size-h)
        
        rect1 = Rect(x,y,w,h,#rects+1)
        overlap = false
        for _,rect2 in pairs(rects)
            if rect1.x+rect1.w>rect2.x and rect2.x+rect2.w>rect1.x and rect1.y+rect1.h>rect2.y and rect2.y+rect2.h>rect1.y
                overlap = true
                    
        if not overlap 
            rects[#rects+1] = rect1
            filled += rect1.w*rect1.h/(size*size)
    
    -- Fills the matrix that makes up the level with information on the rooms already added
    grid = fill_grid(rects,size)
    
    -- Now we have to fill the remaining spaces
        
    -- Find the next empty space
    while true
        found_empty = false
        xempty, yempty = 1,1
        i,j = 1,1
        while i<=size-1 and not found_empty
            while j<=size-1 and not found_empty
                if grid[i][j] == 0
                    xempty, yempty = i,j
                    found_empty = true
                j += 1
            i +=1
            j = 1
                        
        if found_empty == true
            wempty,hempty = 0,0
            i,j = 0,0
            while wempty == 0
                if grid[xempty+i][yempty] != 0 or xempty + i == size-1
                    wempty = i+1
                i += 1
            while hempty == 0
                if grid[xempty][yempty+j] != 0 or yempty + j == size-1
                    hempty = j+1    
                j += 1
                
            found_rect = false
            switch1 = true
            while not found_rect
                found_rect = true
                for i = 0,wempty-1
                    for j = 0,hempty-1
                        if grid[xempty+i][yempty+j] != 0
                            found_rect = false
                                        
                if not found_rect
                    if wempty>hempty
                        if wempty!=1
                            wempty -=1
                        elseif hempty != 1
                            hempty -=1
                        else 
                            found_rect = true
                    else
                        if hempty!=1
                            hempty -=1
                        elseif wempty != 1
                            wempty -=1
                        else 
                            found_rect = true
                    
            rects[#rects+1] = Rect(xempty,yempty,wempty,hempty,#rects+1)
            
            -- fill the rectangle found in the grid
            for m = xempty,xempty+wempty-1
                for n = yempty,yempty+hempty-1
                    grid[m][n] = #rects

        else
            return rects,grid 
    
    return rects,grid 
    

-- returns the coordinates of the door connecting the two rooms if they are near
-- returns false (nil) otherwise
-- works also as a check if two doors are near
get_door = (rect1,rect2) ->
    if rect1.x == rect2.x+rect2.w and rect1.y < rect2.y+rect2.h and rect2.y < rect1.y+rect1.h
        if rect1.y+0.5 > rect2.y 
            return rect1.x,rect1.y+0.5
        else
            return rect1.x,rect2.y+0.5
    if rect2.x == rect1.x+rect1.w and rect1.y < rect2.y+rect2.h and rect2.y < rect1.y+rect1.h
        if rect1.y+0.5 > rect2.y 
            return rect2.x,rect1.y+0.5
        else
            return rect2.x,rect2.y+0.5
    if rect1.y == rect2.y+rect2.h and rect1.x < rect2.x+rect2.w and rect2.x < rect1.x+rect1.w
        if rect1.x+0.5 > rect2.x 
            return rect1.x+0.5,rect1.y
        else
            return rect2.x+0.5,rect1.y
    if rect2.y == rect1.y+rect1.h and rect1.x < rect2.x+rect2.w and rect2.x < rect1.x+rect1.w
        if rect1.x+0.5 > rect2.x 
            return rect1.x+0.5,rect2.y
        else
            return rect2.x+0.5,rect2.y
    return nil,nil
    

generate_doors = (level,size) ->
    doors = {}
    for i=1,#level-1
        for j=i+1,#level
            rect1,rect2 = level[i],level[j]
            if rect1.id != rect2.id
                a,b = get_door(rect1,rect2)
                if a   
                    doors[#doors+1] = {a,b,rect1.id,rect2.id}
    return doors
    

-- Used for debugging
draw_level = (printed, level, grid, doors, size,pps)->
    if printed
        print(#level)
        for _,rect in pairs(level)
            print(rect.x,rect.y,rect.w,rect.h)
        for i=1,size-1
            for j=1,size-1
                io.write(grid[i][j].." ")
            io.write("\n")
        
    -- pixels per square    
    for i=1,size-1
        for j=1,size-1
            love.graphics.setColor(grid[i][j]*20,grid[i][j]*20,grid[i][j]*20)
            love.graphics.rectangle("fill",i*pps,j*pps,pps,pps)
    for _,door in pairs(doors)
        graphics.setColor(255,0,0)
        graphics.rectangle("fill",door[1]*pps,door[2]*pps,5,5)
    

generate.generate_level = generate_level
generate.generate_doors = generate_doors
generate.draw_level = draw_level
generate.get_level = get_level
return generate