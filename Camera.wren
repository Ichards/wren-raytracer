import "Ray" for Ray
import "vec3" for vec3

class Camera {
    construct new(p_lookFrom, p_lookAt, p_vup, p_vfov, p_aspect) {
        _lookFrom = p_lookFrom
        _lookAt = p_lookAt
        _vup = p_vup
        _vfov = p_vfov
        _aspect = p_aspect
    }

    lookFrom {_lookFrom}
    lookAt {_lookAt}   
    vup {_vup}
    vfov {_vfov}
    aspect {_aspect}

    lower_left_corner {_lower_left_corner}
    lower_left_corner = (val) {
        _lower_left_corner = val
    }
    horizontal {_horizontal}
    horizontal = (val) {
        _horizontal = val
    }
    vertical {_vertical}
    vertical = (val) {
        _vertical = val
    }
    origin {_origin}
    origin = (val) {
        _origin = val
    }

}


var initCamera = Fn.new{|p_camera|
    var theta = p_camera.vfov * Num.pi / 180
    var half_height = (theta / 2).tan
    var half_width = p_camera.aspect * half_height

    p_camera.origin = p_camera.lookFrom

    var w = vec3.unitVector(vec3.subtract(p_camera.lookFrom, p_camera.lookAt))
    var u = vec3.unitVector(vec3.cross(p_camera.vup, w))
    var v = vec3.cross(w, u)

    p_camera.lower_left_corner = [-half_width, -half_height, -1]
    p_camera.lower_left_corner = vec3.add([p_camera.origin, vec3.negative(vec3.multiply(u, half_width)), vec3.negative(vec3.multiply(v, half_height)), vec3.negative(w)])
    p_camera.horizontal = vec3.multiply(u, 2*half_width)
    p_camera.vertical = vec3.multiply(v, 2*half_height)
}

var get_ray = Fn.new{|p_u, p_v, p_camera|
    return Ray.new(p_camera.origin, vec3.add([p_camera.lower_left_corner, vec3.multiply(p_camera.horizontal, p_u), vec3.subtract(vec3.multiply(p_camera.vertical, p_v), p_camera.origin)]) )
}