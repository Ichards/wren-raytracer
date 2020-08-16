import "vec3" for vec3, randomSpherePoint
import "Ray" for Ray

class Material {
    construct new (p_matFunc, p_albedo, p_misc) { 
        return [p_matFunc, p_albedo, p_misc]
    }
}


//i suspect target rays are being put to the left more than they should. that means they have a tendency to have a negative x
var lambertianScatter = Fn.new { |p_ray, p_interPoint, p_pointNormal, p_material| //doesn't need ray, but gotta keep it consistent for the metal material function
    //return target
    var spherePoint = randomSpherePoint.call()
    var target = vec3.add([p_interPoint, p_pointNormal, spherePoint])
    var scatterRay = Ray.new(p_interPoint, vec3.subtract(target, p_interPoint))
    return [true, scatterRay]
}

var reflect = Fn.new { |r_direction, v_normal|
    return vec3.subtract(r_direction,vec3.multiply([2, vec3.dot(r_direction, v_normal), v_normal]))
}

var metalScatter = Fn.new { |p_ray, p_interPoint, p_pointNormal, p_material|
    //return target
    var reflection = reflect.call(vec3.unitVector(p_ray.direction), p_pointNormal)
    var didReflect = false
    var scatterRay = Ray.new(p_interPoint, vec3.add(reflection, vec3.multiply(randomSpherePoint.call(), p_material[2][0]))) //that's the fuzz
    if (vec3.dot(scatterRay.direction, p_pointNormal) > 0) {
        didReflect = true
    }
    return [didReflect, scatterRay]
}

