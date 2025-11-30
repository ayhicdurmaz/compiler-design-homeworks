package main

func fibonacci(n int) int {
    if n <= 1 {
        return n
    } else {
        return fibonacci(n-1) + fibonacci(n-2)
    }
}

func main() {
    var result = fibonacci(10)
    var x = 5
    var y = 3.14
    
    if x > 0 {
        x = x * 2
    }
    
    for x > 0 {
        x = x - 1
    }
}
