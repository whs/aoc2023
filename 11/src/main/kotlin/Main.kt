import kotlin.math.abs

fun main() {
//    val factor = 2
    val factor = 1_000_000

    val input = mutableListOf<MutableList<Char>>()
    while (true) {
        input.add(readLine()?.toCharArray()?.toMutableList() ?: break)
    }
    val colsToExpand = findExpandingCol(input)
    val rowsToExpand = findExpandingRow(input)

    // Part 1
//    expandRows(input, rowsToExpand, factor)
//    expandCols(input, colsToExpand, factor)
//    printMap(input)
//    val stars = findStars(input)

    // Part 2
    var stars = findStars(input)
    stars = virtualExpand(stars, rowsToExpand, colsToExpand, factor)
    println(stars)

    val starPairs = combination(stars)
    val sumDistance = starPairs.map { distanceBetween(it.first, it.second) }.sum()
    println(sumDistance)
}

fun virtualExpand(stars: List<Pair<Int, Int>>, rowsToExpand: List<Int>, colsToExpand: List<Int>, factor: Int): List<Pair<Int, Int>> {
    return stars.map {
//        println("expanding $it")
        var row = it.first
        for(expandingRow in rowsToExpand) {
            if (expandingRow < it.first){
                row += factor-1
            }
        }
        var col = it.second
        for(expandingCol in colsToExpand) {
            if (expandingCol < it.second){
//                println("expanding col $expandingCol")
                col += factor-1
            }
        }

//        println("end result ($row, $col)")
        row to col
    }
}

fun printMap(l: List<List<Char>>) {
    for(row in l) {
        for (col in row) {
            print(col)
        }
        println()
    }
}

fun findExpandingCol(l: List<List<Char>>): List<Int> {
    return l[0].indices.filter { col ->
        l.all { it[col] == '.' }
    }
}

fun findExpandingRow(l: List<List<Char>>): List<Int> {
    return l.indices.filter { row ->
        l[row].all { it == '.' }
    }
}

fun findStars(l: List<List<Char>>): List<Pair<Int, Int>> {
    val out = mutableListOf<Pair<Int, Int>>()
    l.mapIndexed { rowId, row ->
        row.mapIndexed { colId, col ->
            if (col == '#') {
                out.add(rowId to colId)
            }
        }
    }
    return out
}

fun expandRows(input: MutableList<MutableList<Char>>, rowsToExpand: List<Int>, factor: Int = 1) {
    var expanded = 0
    for (row in rowsToExpand) {
        val pattern = (0..<input[0].size).map { '.' }.toMutableList()
        val injectedRows = (0..<(factor-1)).map { pattern.toMutableList() }
        val realRow = row + expanded
        input.addAll(realRow, injectedRows)
        expanded += factor
    }
}

fun expandCols(input: MutableList<MutableList<Char>>, colsToExpand: List<Int>, factor: Int = 1) {
    val injectedCols = (0..<(factor-1)).map { '.' }
    for (row in input) {
        var expanded = 0
        for (col in colsToExpand) {
            val realCol = col + expanded
            row.addAll(realCol, injectedCols)
            expanded += factor
        }
    }
}

fun <T> combination(list: List<T>) = sequence {
    list.indices.forEach { a->
        ((a+1)..<list.size).forEach { b->
            yield(list[a] to list[b])
        }
    }
}

fun distanceBetween(first: Pair<Int, Int>, second: Pair<Int, Int>): Long {
    return abs(first.first - second.first).toLong() + abs(first.second - second.second).toLong()
}
