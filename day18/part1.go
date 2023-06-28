package main

import (
	"fmt"
	"io"
	"os"
)

func main() {
	var grid [22][22][22]bool

	surfaceArea := 0
	for {
		var x, y, z int
		_, err := fmt.Scanf("%d,%d,%d", &x, &y, &z)
		if err == io.EOF {
			break
		} else if err != nil {
			fmt.Fprintf(os.Stderr, "scanf: %v", err)
			os.Exit(1)
		}
		grid[z][y][x] = true
		surfaceArea += 6 - countNeighbours(grid, x, y, z)*2
	}

	fmt.Println(surfaceArea)
}

func countNeighbours(grid [22][22][22]bool, x int, y int, z int) int {
	dx := []int{-1, 1, 0, 0, 0, 0}
	dy := []int{0, 0, -1, 1, 0, 0}
	dz := []int{0, 0, 0, 0, -1, 1}
	count := 0
	for i := 0; i < 6; i++ {
		px := x + dx[i]
		py := y + dy[i]
		pz := z + dz[i]
		if px < 0 || py < 0 || pz < 0 || px > 21 || py > 21 || pz > 21 {
			continue
		} else if grid[pz][py][px] {
			count += 1
		}
	}
	return count
}
