import "vec3" for vec3, randomSpherePoint
import "Ray" for Ray
import "Random" for Random

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

var refract = Fn.new { |p_ray, p_normal, p_ni_over_nt|
    var unitRay = vec3.unitVector(p_ray)
    var dt = vec3.dot(unitRay, p_normal)
    var discriminant = 1 - (p_ni_over_nt * p_ni_over_nt * (1-dt*dt))
    if (discriminant > 0) {
        //in the original source code, the result is put into a referenced parameter, but wren can't do that :D


        var a = vec3.multiply((vec3.subtract(unitRay, vec3.multiply(p_normal,dt))), p_ni_over_nt)
        var b = p_normal
        var c = discriminant.sqrt
        var c2 = vec3.multiply(p_normal, discriminant.sqrt)

        //var refracted = vec3.multiply((vec3.subtract(unitRay, vec3.multiply(p_normal,dt))), p_ni_over_nt) - p_normal*discriminant.sqrt

        var refracted2 = vec3.subtract(a,c2)

        
        return [true, refracted2]
    } else {
        return [false, 0]
    }

    //return "pee"

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

var schlick = Fn.new { |p_cosine, p_ref_idx|
    var r0 = (1-p_ref_idx) / (1+p_ref_idx)
    r0 = r0 * r0
    return r0 + (1-r0)*(1-p_cosine).pow(5)
}

var dielectricScatter = Fn.new { |p_ray, p_interPoint, p_pointNormal, p_material|
    var outward_normal
    var reflected = reflect.call(p_ray.direction, p_pointNormal)
    var ni_over_nt
    var refracted
    var scatterRay

    var reflect_prob
    var cosine

    if (vec3.dot(p_ray.direction, p_pointNormal) > 0) {
        //outward_normal = vec3.multiply(p_pointNormal, -1)
        outward_normal = vec3.negative(p_pointNormal)
        ni_over_nt = p_material[2][0]
        //refractive index is the 0th misc parameter for dielectric materialz!!!! :D
        cosine = p_material[2][0] * vec3.dot(p_ray.direction, p_pointNormal) / vec3.length(p_ray.direction) 
    } else {
        outward_normal = p_pointNormal
        ni_over_nt = 1 / p_material[2][0]
        cosine = -vec3.dot(p_ray.direction, p_pointNormal) / vec3.length(p_ray.direction)
    }
    var refractResult = refract.call(p_ray.direction, outward_normal, ni_over_nt)
    if (refractResult[0]) {
        //scatterRay = Ray.new(p_interPoint, refractResult[1])
        reflect_prob = schlick.call(cosine, p_material[2][0])
    } else {
        //scatterRay = Ray.new(p_interPoint, reflected) //feel like this is unnecessary / redundant
        //bingo. peter shirely agreed with me :D
        reflect_prob = 1
        //return [false, scatterRay]
    }

    if (Random.randomLTO() < reflect_prob) {
        scatterRay = Ray.new(p_interPoint, reflected)
    } else {
        scatterRay = Ray.new(p_interPoint, refractResult[1])
    }

    return [true, scatterRay]

    //return [true, scatterRay]
}

