using System.Diagnostics;

var _grid = new List<char[]>();

using (var input = new StreamReader(args[0]))
{
    while (!input.EndOfStream)
    {
        _grid.Add(input.ReadLine()!.ToCharArray());
    }
}

var grid = new char[_grid.Count, _grid[0].Length];
for (int row = 0; row < _grid.Count; row++)
{
    for (int col = 0; col < _grid[row].Length; col++)
    {
        grid[row, col] = _grid[row][col];
    }
}

// row, col
(int, int) GetStartingPos()
{
    for (int row = 0; row < grid.GetLength(0); row++)
    {
        for (int col = 0; col < grid.GetLength(1); col++)
        {
            if (grid[row, col] == 'S')
            {
                return (row, col);
            }
        }
    }

    throw new UnreachableException("no starting point found");
}
var startingPos = GetStartingPos();
var distanceGrid = MakeDistanceGrid();

int[,] MakeDistanceGrid()
{
    int[,] dg = new int[grid.GetLength(0), grid.GetLength(1)];

    for (int i = 0; i < dg.GetLength(0); i++)
    {
        for (int j = 0; j < dg.GetLength(1); j++)
        {
            dg[i,j] = Int32.MaxValue;
        } 
    }

    // XXX: Starting position value is 1 NOT 0 as indicated in problem statement
    dg[startingPos.Item1, startingPos.Item2] = 1;
    return dg;
}

void PrintGrid(char[,] g)
{
    for (int i = 0; i < g.GetLength(0); i++)
    {
        for (int j = 0; j < g.GetLength(1); j++)
        {
            Console.Write(g[i, j]);
        } 
        Console.WriteLine();
    }
}

void PrintDistanceGrid(int[,] g)
{
    for (int i = 0; i < g.GetLength(0); i++)
    {
        for (int j = 0; j < g.GetLength(1); j++)
        {
            var val = g[i, j];
            if (val == int.MaxValue)
            {
                Console.Write(" " + grid[i, j]);   
            }
            else
            {
                Console.Write(string.Format("{0:00}", g[i,j]-1));
            }
            Console.Write(" ");
        } 
        Console.WriteLine();
    }
}

int GridMax(int[,] grid)
{
    int max = 0;
    for (int i = 0; i < grid.GetLength(0); i++)
    {
        for (int j = 0; j < grid.GetLength(1); j++)
        {
            var val = grid[i, j];
            if (val == int.MaxValue)
            {
                continue;
            }

            max = Math.Max(max, val);
        } 
    }

    return max;
}


void BFS((int, int) position)
{
    var fillValue = distanceGrid[position.Item1, position.Item2] + 1;
    var currentCell = grid[position.Item1, position.Item2];
    var queue = new List<(int, int)>();
    // Pipes: |-LJ7FS
    // Check north
    if (position.Item1 - 1 >= 0)
    {
        var cell = (position.Item1 - 1, position.Item2);
        if (distanceGrid[cell.Item1, cell.Item2] > fillValue && "|7F".Contains(grid[cell.Item1, cell.Item2]) && "S|LJ".Contains(currentCell))
        {
            distanceGrid[cell.Item1, cell.Item2] = fillValue;
            queue.Add(cell);
        }
    }
    // Check west
    if (position.Item2 - 1 >= 0)
    {
        var cell = (position.Item1, position.Item2 - 1);
        if (distanceGrid[cell.Item1, cell.Item2] > fillValue && "-LF".Contains(grid[cell.Item1, cell.Item2]) && "S-J7".Contains(currentCell))
        {
            distanceGrid[cell.Item1, cell.Item2] = fillValue;
            queue.Add(cell);
        }
    }
    // Check south
    if (position.Item1 + 1 < grid.GetLength(0))
    {
        var cell = (position.Item1 + 1, position.Item2);
        if (distanceGrid[cell.Item1, cell.Item2] > fillValue && "|LJ".Contains(grid[cell.Item1, cell.Item2]) && "S|7F".Contains(currentCell))
        {
            distanceGrid[cell.Item1, cell.Item2] = fillValue;
            queue.Add(cell);
        }
    }
    // Check east
    if (position.Item2 + 1 < grid.GetLength(1))
    {
        var cell = (position.Item1, position.Item2 + 1);
        if (distanceGrid[cell.Item1, cell.Item2] > fillValue && "-J7".Contains(grid[cell.Item1, cell.Item2]) && "S-LF".Contains(currentCell))
        {
            distanceGrid[cell.Item1, cell.Item2] = fillValue;
            queue.Add(cell);
        }
    }
    
    // BFS
    foreach(var q in queue)
    {
        BFS(q);
    }
}

// Part 1
// BFS(startingPos);
// PrintDistanceGrid(distanceGrid);
// Console.WriteLine(gridMax(distanceGrid) - 1);

char[,] DoubleGrid()
{
    // Double the grid resolution
    var newGrid = new char[grid.GetLength(0) * 2, grid.GetLength(1) * 2];
    for (int row = 0; row < grid.GetLength(0); row++)
    {
        for (int col = 0; col < grid.GetLength(1); col++)
        {
            var mappedRow = row * 2;
            var mappedCol = col * 2;
            newGrid[mappedRow, mappedCol] = grid[row, col];
            newGrid[mappedRow+1, mappedCol+1] = '.';
            switch (grid[row, col])
            {
                case '|':
                    // |.
                    // |.
                    newGrid[mappedRow, mappedCol+1] = '.';
                    newGrid[mappedRow+1, mappedCol] = '|';
                    break;
                case '-':
                    // --
                    // ..
                    newGrid[mappedRow, mappedCol+1] = '-';
                    newGrid[mappedRow+1, mappedCol] = '.';
                    break;
                case 'L':
                    // L-
                    // ..
                    newGrid[mappedRow, mappedCol+1] = '-';
                    newGrid[mappedRow+1, mappedCol] = '.';
                    break;
                case 'J':
                    // J.
                    // ..
                    newGrid[mappedRow, mappedCol+1] = '.';
                    newGrid[mappedRow+1, mappedCol] = '.';
                    break;
                case '7':
                    // 7.
                    // |.
                    newGrid[mappedRow, mappedCol+1] = '.';
                    newGrid[mappedRow+1, mappedCol] = '|';
                    break;
                case 'F':
                    // F-
                    // |.
                    newGrid[mappedRow, mappedCol+1] = '-';
                    newGrid[mappedRow+1, mappedCol] = '|';
                    break;
                case '.':
                    // ..
                    // ..
                    newGrid[mappedRow, mappedCol+1] = '.';
                    newGrid[mappedRow+1, mappedCol] = '.';
                    break;
                case 'S':
                    // S-
                    // |.
                    newGrid[mappedRow, mappedCol+1] = '-';
                    newGrid[mappedRow+1, mappedCol] = '|';
                    break;
            }
        }
    }

    return newGrid;
}

grid = DoubleGrid();
startingPos = GetStartingPos();
distanceGrid = MakeDistanceGrid();

BFS(startingPos);

// Remove irrelevant grid positions
for (int row = 0; row < distanceGrid.GetLength(0); row++)
{
    for (int col = 0; col < distanceGrid.GetLength(1); col++)
    {
        if (distanceGrid[row, col] == int.MaxValue)
        {
            grid[row, col] = '.';
        }
    }
}

PrintDistanceGrid(distanceGrid);

void FloodFill((int, int) position)
{
    if (grid[position.Item1, position.Item2] != '.')
    {
        return;
    }

    grid[position.Item1, position.Item2] = 'O';
    // top
    if (position.Item1 - 1 >= 0)
    {
        FloodFill((position.Item1-1, position.Item2));
    }
    // left
    if (position.Item2 - 1 >= 0)
    {
        FloodFill((position.Item1, position.Item2-1));
    }
    // south
    if (position.Item1 + 1 < grid.GetLength(0))
    {
        FloodFill((position.Item1+1, position.Item2));
    }
    // right
    if (position.Item2 + 1 < grid.GetLength(1))
    {
        FloodFill((position.Item1, position.Item2+1));
    }
}

// Flood fill the edges with O
for (int i = 0; i < grid.GetLength(0); i++)
{
    // Fill left edge
    FloodFill((i, 0));
    // Fill right edge
    FloodFill((i, grid.GetLength(1) - 1));
}

for (int i = 0; i < grid.GetLength(1); i++)
{
    // Fill top edge
    FloodFill((0, i));
    // Fill bottom edge
    FloodFill((grid.GetLength(0)-1, i));
}
PrintGrid(grid);

int CountHalfDots()
{
    int accum = 0;
    for (int row = 0; row < grid.GetLength(0); row += 2)
    {
        for (int col = 0; col < grid.GetLength(1); col += 2)
        {
            if (grid[row, col] == '.')
            {
                accum++;
            }
        }
    }

    return accum;
}

Console.WriteLine(CountHalfDots());