# 7.5. Основы golang

## Программа перевода метров в футы

```golang
package main

import (
    "fmt"
    "path"
    "os"
    "strconv"
)

func getNumber() float64 {
    number, err := strconv.ParseFloat( os.Args[1], 64)
    if err != nil {
        // handle error
        fmt.Println(err)
        os.Exit(2)
    }
    return float64(number)
}


func main() {
    var input, output float64

    if len(os.Args) == 1 {
        fmt.Print("Enter a meters: ")
        fmt.Scanf("%f", &input)
    } else {
        input = getNumber()
    }

    switch path.Base(os.Args[0]) {
        case "m2f": {
            output = input / 0.3048
            fmt.Printf("%.2f meter(s) is %.05f foots\n", input, output)
        }
        case "f2m": {
            output = input * 0.3048
            fmt.Printf("%.2f foot(s) is %.05f meterss\n", input, output)
        }
        default:
            fmt.Println("only m2f and f2m supported")
    }
}
```
____

## Программа поиска наименьшего элемента в масиве

```golang
package main

import "fmt"

func my_min(x [] int) (int, int, error) {
  if len(x) == 0 {
    return 0,0, fmt.Errorf("Array is empty")
  }
  min := x[0]
  idx := 0
  for i, v := range x {
    if v < min {
       idx = i
       min = v
    }
  }
  return min, idx, nil
}

func main() {
  x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}

  min, idx, err  := my_min(x)

  if err != nil {
    fmt.Printf("Error: %s\n", err)
    return
  }

  fmt.Println("List: ", x)
  fmt.Printf("Minimal element %d at position %d\n", min, idx)
}
```
____

## Тест поиска наименьшего элемента в масиве

Пример запуска теста _go test min.go min_test.go_

```go
package main

import (
    "testing"
)

func TestCircle(t *testing.T) {
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    good, _, err := my_min(x)
    if (good != 9) || (err != nil) {
	t.Fatalf("Want %v, but got %v", good, 9)
    }

    var y  []int
    _, _, err = my_min(y)
    if err == nil {
	t.Fatalf("Empty array detected")
    }

    _, _, err = my_min(nil)
    if err == nil {
	t.Fatalf("Empty array detected")
    }
}
```
____

## Вывод всех чисел от 1 до 100, которые без остатка делятся на 3

```golang
package main

import "fmt"

func main() {
  for i:=1; i<=100; i++ {
    if i % 3 == 0 {
      fmt.Print(i, " ")
    }
  }
  fmt.Println()
}
```

## Программное извлечение квадратного корня
Для сборки используйте команду  
$ _go build sqrt.go_  
Для вычисления корня используй команду  
$ _go run sqrt.go <число>_  
или  
$ _./sqrt <число>_  

```golang sqrt.go
package main

import (
    "fmt"
    "os"
    "os/exec"
    "strconv"
)

func Квадратный_корень(x float64) float64 {
  z := 1.0
  for i:=0; i<16; i++ {
    z -= (z*z - x) / (2*z)
//    fmt.Println(i,z)
  }
  return z
}

// Это пошло. Но работает. Не делайте так.
func Очистка_экрана() {
        cmd := exec.Command("clear") //Linux example, its tested
        cmd.Stdout = os.Stdout
        cmd.Run()
}

func ClearScreen() {
    fmt.Printf("\033c")
}

func Получение_числа() float64 {
    number, err := strconv.Atoi( os.Args[1])
    if err != nil {
        // handle error
        fmt.Println(err)
        os.Exit(2)
    }
    if number < 0 {
        fmt.Println("Невозможно извлечь корень из отрицательного числа")
        os.Exit(3)
    }
    return float64(number)
}

func main() {
    var number float64
    if len(os.Args) == 1 {
        ClearScreen()
        fmt.Println("Use:\nsqrt <number>\n  где <number> это неотрицательное число\n  пример: sqrt 81")
        os.Exit(1)
    } else {
        number = Получение_числа()
    }
    fmt.Println( "Корнем числа", number, "является", Квадратный_корень(number))
}
```
