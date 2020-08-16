import "vec3" for vec3

class Ray {
    construct new(p_origin, p_direction) {
        _origin = p_origin
        _direction = p_direction
    }
    origin {_origin}
    direction {_direction}
}

var pointAtPar = Fn.new {|p_ray, p_t|
    return vec3.add(p_ray.origin, vec3.multiply(p_ray.direction, p_t))
}

//this function returns a white/blue color depending on the normal
var colorizeNormal = Fn.new{ |p_rayDirection|
    var unitDirection = vec3.unitVector(p_rayDirection)
    var blue = [0.5, 0.7, 1]
    var white = [1, 1, 1]
    var blueStrength = unitDirection[1]
    blueStrength = (blueStrength + 1) * 0.5
    return vec3.add(vec3.multiply(blue, blueStrength),vec3.multiply(white, 1-blueStrength))
}