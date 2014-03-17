utils = {}

toggle = (bool) ->
    if bool
        return false
    else
        return true
        
        
level = (val,min) ->
    if val<min
        return min
    return val
        
        
trim = (val,max) ->
    if val>max
        return max
    return val
    
        
norm = (m,s) ->
    return math.floor(math.pow(math.random!*2-1,3)*s+m) 


utils.toggle = toggle
utils.level = level
utils.trim = trim
utils.norm = norm

return utils
