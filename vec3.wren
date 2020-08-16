import "Random" for Random
//alright i give up
//the vec3 is going to be replaced by lists, with a vec3 class containing
//static functions to perform operations.
class vec3 {
    static negative(l_val) {
        return [-l_val[0], -l_val[1], -l_val[2]]
    }
    static add(l_val1, l_val2) {
        return [l_val1[0] + l_val2[0], l_val1[1] + l_val2[1], l_val1[2] + l_val2[2]]
    }
    static subtract(l_val1, l_val2) {
        return this.add(l_val1, this.negative(l_val2))
    }
    static add(l_vals) {
        var f_val = [0, 0, 0]
        for (l_val in l_vals) {
            f_val = this.add(f_val, l_val)
        }
        return f_val
    }
    static multiply(l_val1, l_val2) {
        if (l_val2 is Num) {
            return [l_val1[0] * l_val2, l_val1[1] * l_val2, l_val1[2] * l_val2]
        } //i guess the "else" here is implied, lmao
        return [l_val1[0] * l_val2[0], l_val1[1] * l_val2[1], l_val1[2] * l_val2[2]]
    }
    static multiply(l_vals) {
        var f_val = [1, 1, 1]
        for (l_val in l_vals) {
            f_val = this.multiply(f_val, l_val)
        }
        return f_val
    }
    static divide(l_val1, l_val2) {
        if (l_val2 is Num) {
            return [l_val1[0] / l_val2, l_val1[1] / l_val2, l_val1[2] / l_val2]
        }
        return [l_val1[0] / l_val2[0], l_val1[1] / l_val2[1], l_val1[2] / l_val2[2]]
    }
    static unitVector(l_val) {
        var k = 1 / (l_val[0] * l_val[0] + l_val[1] * l_val[1] + l_val[2] * l_val[2]).sqrt
        return this.multiply(l_val, k)
    }
    static dot(l_val1, l_val2) {
        return (l_val1[0] * l_val2[0] + l_val1[1] * l_val2[1] + l_val1[2] * l_val2[2])
    }
    static cross(l_val1, l_val2) {
        var p_x = l_val1[1] * l_val2[2] - l_val1[2] * l_val2[1]
        var p_y = -(l_val1[0] * l_val2[2] - l_val1[2] * l_val2[0])
        var p_z = l_val1[0] * l_val2[1] - l_val1[1] * l_val2[0]
        return [p_x, p_y, p_z]
    }
    static length(l_val) {
        return (l_val[0] * l_val[0] + l_val[1] * l_val[1] + l_val[2] * l_val[2]).sqrt
    }
    static squaredLength(l_val) {
        return (l_val[0] * l_val[0] + l_val[1] * l_val[1] + l_val[2] * l_val[2])
    }
    static power(l_val, n_val) {
        return [l_val[0].pow(n_val), l_val[1].pow(n_val), l_val[2].pow(n_val)]
    }

    static print(l_val) {
        System.print("[%(l_val[0]) %(l_val[1]) %(l_val[2])]")
    }
}



var randomSpherePoint = Fn.new {
    //felt like making a recursive function, gonna resist that urge since it seems unnecessary and potentially annoying
    var point = [0, 0, 0]
    var lost = true
    while (lost) {
        point[0] = 2 * (Random.randomLTO() - 0.5)
        point[1] = 2 * (Random.randomLTO() - 0.5)
        point[2] = 2 * (Random.randomLTO() - 0.5)
        if (vec3.squaredLength(point) < 1) {
            lost = false
        }
    }
    return point
}
