class Random { //lol class
    foreign static random(p_max) //can't go above a 4 byte uint val 
    
    static numberShrink(p_num) { //just realized i could just progressively divide by 10 until i get the number i want instead of storing a counter and using it as an exponent....
        var count = 1
        while (true) {
            if (p_num / (10.pow(count)) > 1) {
                count = count + 1
            } else {
                return p_num / 10.pow(count)
                break
            }
        }
    }
    
    static randomLTO() {
        var startNumber = this.random(10000) //4294967295 was once used, but it seemed to tamper with the results
        return this.numberShrink(startNumber)
    }
}




