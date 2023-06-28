package main

import (
	"fmt"
	"io"
	"os"
)

func main() {
	var grid [22][22][22]bool

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
	}

	var outside [22][22][22]bool
	// fill the outside area
	floodfill(&outside, &grid, 0, 0, 0)

	surfaceArea := 0
	for z := 0; z < 22; z++ {
		for y := 0; y < 22; y++ {
			for x := 0; x < 22; x++ {
				if outside[z][y][x] {
					// add on surface area where outside touches grid
					surfaceArea += countNeighbours(grid, x, y, z)
				}

				// awful hack: add on faces that touch the limits of the grid
				if x == 0 || y == 0 || z == 0 || x == 21 || y == 21 || z == 21 {
					if grid[z][y][x] {
						surfaceArea += 1
					}
				}
			}
		}
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

func floodfill(outside *[22][22][22]bool, grid *[22][22][22]bool, x int, y int, z int) {
	if outside[z][y][x] || grid[z][y][x] {
		return
	}
	outside[z][y][x] = true
	dx := []int{-1, 1, 0, 0, 0, 0}
	dy := []int{0, 0, -1, 1, 0, 0}
	dz := []int{0, 0, 0, 0, -1, 1}
	for i := 0; i < 6; i++ {
		px := x + dx[i]
		py := y + dy[i]
		pz := z + dz[i]
		if px < 0 || py < 0 || pz < 0 || px > 21 || py > 21 || pz > 21 || outside[pz][py][px] || grid[pz][py][px] {
			continue
		} else {
			floodfill(outside, grid, px, py, pz)
		}
	}
}
