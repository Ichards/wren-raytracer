import "vec3" for vec3, randomSpherePoint
import "File" for File
import "Ray" for Ray, pointAtPar, colorizeNormal
import "Marble" for Marble
import "Random" for Random
import "Output" for Output
import "Material" for Material, lambertianScatter, metalScatter, reflect

System.print("PLEEEASE")


var hit_record = {
    "t": 0,
    "point": [0, 0, 0],
    "normal": [0, 0, 0],
    "material": Fn.new{ System.print("no material") },
}


var collide = Fn.new { |p_ray, p_tmin, p_tmax, p_marble| //see if a ray collides with the marble. put point of intersection into outside struct, return bool
    var a = ((p_ray.direction[0] * p_ray.direction[0]) + (p_ray.direction[1] * p_ray.direction[1]) + (p_ray.direction[2] * p_ray.direction[2]))
    var b = 2 * ( (p_ray.origin[0] * p_ray.direction[0] - p_ray.direction[0] * p_marble[0][0]) + (p_ray.origin[1] * p_ray.direction[1] - p_ray.direction[1] * p_marble[0][1]) + (p_ray.origin[2] * p_ray.direction[2] - p_ray.direction[2] * p_marble[0][2]) )
    var c = ( (p_ray.origin[0] * p_ray.origin[0] + p_marble[0][0] * p_marble[0][0] - 2 * p_ray.origin[0] * p_marble[0][0]) + (p_ray.origin[1] * p_ray.origin[1] + p_marble[0][1] * p_marble[0][1] - 2 * p_ray.origin[1] * p_marble[0][1]) + (p_ray.origin[2] * p_ray.origin[2] + p_marble[0][2] * p_marble[0][2] - 2 * p_ray.origin[2] * p_marble[0][2])) - (p_marble[1] * p_marble[1])
    var discriminant = b * b - 4 * a * c
    if (discriminant > 0) {
        var t = (-b - discriminant.sqrt) / (2 * a)
        if (t > p_tmin && t < p_tmax) {
            hit_record["t"] = t
            var intersectionPoint = pointAtPar.call(p_ray, t)
            hit_record["point"] = intersectionPoint
            hit_record["normal"] = vec3.unitVector(vec3.subtract(intersectionPoint,p_marble[0]))
            hit_record["material"] = p_marble[2]
            return true
        }
    }
    return false
}

var collideList = Fn.new { |p_ray, p_tmin, p_tmax, p_marbleList|
    var hasHit = false
    var b_hit_record = {
        "t": Num.largest,
        "point": [0, 0, 0],
        "normal": [0, 0, 0],
        "material": Fn.new{ System.print("no material") }
    }
    for (marble in p_marbleList) {
        //collide with every marble in the list, only save it when the t is as short as possible
        //i guess i'll just make my own struct here, and push it at the end to the "official" struct
        //once i know it's the greatest and smallest t
        if (collide.call(p_ray, 0, Num.largest, marble)) {
            hasHit = true
            if (hit_record["t"] < b_hit_record["t"]) {
                b_hit_record["t"] = hit_record["t"]
                b_hit_record["point"] = hit_record["point"]
                b_hit_record["normal"] = hit_record["normal"]
                b_hit_record["material"] = hit_record["material"]
            }
        }
    }
    hit_record = b_hit_record //finally setting the official struct to the victor with the smallest t
    return hasHit
}


var rayColor = Fn.new{ |p_ray, p_marbleList|
    var c_ray = p_ray
    var bounce = 0
    var albedoList = []
    while (collideList.call(c_ray, 0.001, Num.largest, p_marbleList)) {
        bounce = bounce + 1 //GOTTA limit bounces
        if (bounce > 10) {
            return [0, 0, 0]
        }
        albedoList.add(hit_record["material"][1])
        c_ray = hit_record["material"][0].call(c_ray, hit_record["point"], hit_record["normal"], hit_record["material"])[1]
    }

    var endColor = colorizeNormal.call(c_ray.direction)

    for (l_val in albedoList) {
        endColor = vec3.multiply(endColor, l_val)
    }

    return endColor
}


//set up image
var imageName = "render.ppm"
System.print("WRITING TO " + imageName)
File.open(imageName)
var width = 200
var height = 100
var maxColorValue = 255 //takes one byte, but wren only uses 16-bit doubles i think, lmao
File.write("P3\n%(width) %(height)\n%(maxColorValue)\n")
File.close()

var lower_left_corner = [-2, -1, -1]
var horizontal = [4, 0, 0]
var top = [0, 2, 0]
var cameraOrigin = [0, 0, 0]

var marbleList = [Marble.new([0, 0, -1], 0.5, Material.new(lambertianScatter, [0.5, 0.5, 0.5], [])), Marble.new([0, -100.5, -1], 100, Material.new(lambertianScatter, [0.5, 0.5, 0.5], [])),
Marble.new([1, 0, -1], 0.5, Material.new(metalScatter, [0.8, 0.6, 0.2], [0.35])), Marble.new([-1, 0, -1], 0.5, Material.new(metalScatter, [0.8, 0.8, 0.8], [0])) ]
//                                                                  ^                       ^^                                                                              ^                       ^^

File.openAppend(imageName)

var asCount = 1

//EXPERIMENTAL, MAKING PROGRESS BAR

var totalRayCount = width * height * asCount
//totalRayCount / 10. 
var progressChunks = (totalRayCount / 10).floor

var progressCount = 0

var totalProgress = 0

var progressString = ""

System.print("Progress")

//EXPERIMANTAL OVER


//I'll make the image left to right, top to bottom to follow the guide
for (y in height-1..0) { //99-0
    for (x in 0...width) {//0-199
        var color = [0, 0, 0]
        for (currentAs in 0...asCount) {
            var yStrength = (y + (Random.randomLTO() - 1)) / (height-1)
            var xStrength = (x + (Random.randomLTO() - 1)) / (width-1)
            var ray = Ray.new(cameraOrigin, vec3.add([lower_left_corner, vec3.multiply(horizontal, xStrength), vec3.multiply(top, yStrength)]))
            color = vec3.add(color, rayColor.call(ray, marbleList))
            progressCount = progressCount + 1
        }
        color = vec3.divide(color, asCount)
        color = [color[0].sqrt, color[1].sqrt, color[2].sqrt]

        var redValue = (color[0] * 255).round
        var greenValue = (color[1] * 255).round
        var blueValue = (color[2] * 255).round
        File.write("%(redValue) %(greenValue) %(blueValue)\n")
        //alright, just made and processed the ray, let's get this bread
        
        if (progressCount >= progressChunks) {
            progressCount = 0 //afraid of the value getting too high
            var sp_string = ""
            for (spaces in 10...totalProgress) {
                sp_string = sp_string + " "
            }
            Output.flushOutput(progressString + ">" + sp_string + "|" + "\r")
            progressString = progressString + "="
            totalProgress = totalProgress + 1
            Output.makeSound(150, 200)
        }
    }
}
File.close()

Output.makeSound(250, 1000)

