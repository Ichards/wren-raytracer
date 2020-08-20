import "Ray" for Ray
import "vec3" for vec3
import "Random" for Random

class Camera {
    construct new(p_lookFrom, p_lookAt, p_vup, p_vfov, p_aspect, p_aperture, p_focus_dist) {
        _lookFrom = p_lookFrom
        _lookAt = p_lookAt
        _vup = p_vup
        _vfov = p_vfov
        _aspect = p_aspect
        _aperture = p_aperture
        _focus_dist = p_focus_dist

        _lens_radius = p_aperture / 2
    }

    lookFrom {_lookFrom}
    lookAt {_lookAt}   
    vup {_vup}
    vfov {_vfov}
    aspect {_aspect}

    aperture {_aperture}
    focus_dist {_focus_dist}

    lens_radius {_lens_radius}

    u {_u}
    u = (val) {
        _u = val
    }

    v {_v}
    v = (val) {
        _v = val
    }

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


var random_in_unit_disk = Fn.new {
    var p = [2, 2, 2]
    while (vec3.dot(p, p) > 1) {
        p = vec3.subtract(vec3.multiply([Random.randomLTO(), Random.randomLTO(), 0], 2), [1, 1, 0])
    }
    return p
}


var initCamera = Fn.new{|p_camera|
    var theta = p_camera.vfov * Num.pi / 180
    var half_height = (theta / 2).tan
    var half_width = p_camera.aspect * half_height

    p_camera.origin = p_camera.lookFrom

    var w = vec3.unitVector(vec3.subtract(p_camera.lookFrom, p_camera.lookAt))
    var u = vec3.unitVector(vec3.cross(p_camera.vup, w))
    var v = vec3.cross(w, u)

    p_camera.u = u
    p_camera.v = v

    p_camera.lower_left_corner = [-half_width, -half_height, -1]
    p_camera.lower_left_corner = vec3.add([p_camera.origin, vec3.negative(vec3.multiply([u, half_width, p_camera.focus_dist])), vec3.negative(vec3.multiply([v, half_height, p_camera.focus_dist])), vec3.negative(vec3.multiply(w, p_camera.focus_dist))])
    p_camera.horizontal = vec3.multiply(u, 2*half_width*p_camera.focus_dist)
    p_camera.vertical = vec3.multiply(v, 2*half_height*p_camera.focus_dist)
}

var get_ray = Fn.new{|p_u, p_v, p_camera|
    var rd = vec3.multiply(random_in_unit_disk.call(),p_camera.lens_radius)


    var offset = 5

    offset = vec3.add(vec3.multiply(p_camera.u, rd[0]),vec3.multiply(p_camera.v, rd[1]))
    
    return Ray.new(vec3.add(p_camera.origin, offset), vec3.add([p_camera.lower_left_corner, vec3.multiply(p_camera.horizontal, p_u), vec3.multiply(p_camera.vertical, p_v), vec3.negative(p_camera.origin), vec3.negative(offset)]) )
}