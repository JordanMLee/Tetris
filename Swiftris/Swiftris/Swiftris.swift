//
//  Swiftris.swift
//  Swiftris
//
//  Created by Restricted on 12/30/17.
//  Copyright © 2017 Bloc. All rights reserved.
//

// #5 define total number of rows and columns on the game board, and the location of where each piece starts and the location of where the preview piece belongs
//game initialization constants
let NumColumns = 10
let NumRows = 20
let StartingColumn = 4
let StartingRow = 0
let PreviewColumn = 12
let PreviewRow = 1


//scoring constants
let PointsPerLine = 10
let LevelThreshold = 500

//protocol specifically designed to receive updates from the Swiftris class
protocol SwiftrisDelegate {
    
    // Invoked when the current round of Swiftris ends
    func gameDidEnd(swiftris: Swiftris)
    
    
    // Invoked adter a new game has begun
    func gameDidBegin(swiftris:Swiftris)
    
    
    // Invoked when the falling shape has become part of the game board
    func gameShapeDidLand(swiftris: Swiftris)
    
    
    // Invoked when the falling shape has changed its location
    func gameShapeDidMove(swiftris: Swiftris)
    
    // Invoked when the falling shape has changed its location after being dropped
    func gameShapeDidDrop(swiftris: Swiftris)
    
    
    // Invoked when the game has reached a new level
    func gameDidLevelUp(swiftris: Swiftris)
    

}

class Swiftris {
    //setup game variables
    
    var blockArray:Array2D<Block>
    var nextShape:Shape?
    var fallingShape:Shape?
    //Swiftris notifies the delegate of events throughout the course of th game. GameViewController will attach itself as the delegate to update the user interface and react to game state changes whenever something occurs inside of the Swiftris class
    
    //initial score and level variables
    
    var score = 0
    var level = 1
    
    //delegate object for SwiftrisDelegate protocol
    var delegate:SwiftrisDelegate?
    
    //initialize swiftris class objects
    init() {
        fallingShape = nil
        nextShape = nil
        blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
    }
    
    func beginGame() {
        if (nextShape == nil){
            nextShape = Shape.random(startingColumn: PreviewColumn, startingRow:PreviewRow)
        }
        
        delegate?.gameDidBegin(swiftris: self)
    }
    
// #6
    //func that returns the current falling shape the next one after that
    //functions calls live here
    func newShape() -> (fallingShape:Shape?, nextShape:Shape?) {
       fallingShape = nextShape
       nextShape = Shape.random(startingColumn: PreviewColumn, startingRow: PreviewRow)
       fallingShape?.moveTo(column: StartingColumn, row: StartingRow)
        
// #1  logic to detect the ending of a swiftris game (The game ends when a new shape located at the designated starting location collides with an existing block
        guard detectIllegalPlacement() == false else {
            nextShape = fallingShape
            nextShape!.moveTo(column: PreviewColumn, row: PreviewRow)
            endGame()
            return (nil, nil)
        }
        
        
        
       return(fallingShape,nextShape)
        
    }
// #2 detect if block exceeds the legal size of the game board or if block's current location overlaps with an existing block
    func detectIllegalPlacement() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        
        for block in shape.blocks {
            if block.column  < 0 || block.column >= NumColumns || block.row < 0 || block.row >= NumRows {
                return true
            } else if blockArray[block.column, block.row] != nil {
                return true
            }
        }
    return false
        
    }
    
// #4 drop shapes immediately to speed up game
    func dropShape() {
        guard let shape = fallingShape else {
            return
        }
        //if illegal placement, raise shape and notify the delegate that a drop has occured
        while detectIllegalPlacement() == false {
            shape.lowerShapeByOneRow()
        }
        
        shape.raiseShapeByOneRow()
        delegate?.gameShapeDidLand(swiftris: self)
    }
    
// #5 called once every tick.  Attempts to lower the shape by one row and ends the game if it fails to do so without finding legal placement for it.
    func letShapeFall() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.lowerShapeByOneRow()
        
        if detectIllegalPlacement() {
            shape.raiseShapeByOneRow()
            if detectIllegalPlacement() {
                endGame()
            } else {
                settleShape()
            }
        }
    }
    //rotate tthe shape clockwise as it falls, if it is an illegal move
    func rotateShape() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.rotateClockwise()
        guard detectIllegalPlacement() == false else {
            shape.rotateCounterClockwise()
            return
        }
        
        delegate?.gameShapeDidMove(swiftris: self)
    }
// #7 move shape left or right
    func moveShapeLeft() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.shiftLeftByOneColumn()
        
        guard detectIllegalPlacement() == false else {
            shape.shiftRightByOneColumn()
            return
        }
        
        delegate?.gameShapeDidMove(swiftris: self)
        
    }
    
    func moveShapeRight() {
        guard let shape = fallingShape else {
            return
        }
        
        shape.shiftRightByOneColumn()
        guard detectIllegalPlacement() == false else {
            shape.shiftLeftByOneColumn()
            return
        }
        
        delegate?.gameShapeDidMove(swiftris: self)
    }
// #8: settleShape() adds the falling shape to the collection of blocks maintained by Swiftris.  Once the falling shape's blocks are part of the game board, we nullify fallingShape and notify the delegate of a new shape settling onto the game board
    func settleShape() {
        guard let shape = fallingShape else {
            return
        }
        for block in shape.blocks {
            blockArray[block.column,block.row] = block
        }
        
        fallingShape = nil
        delegate?.gameShapeDidLand(swiftris:self)
    }
    
// #9 detects when a shape should settle, if the shapes' bottom blocks touches a block on the game board or when one of those same blocks has reached the bottom of the game board
    
    func detectTouch() -> Bool {
        guard let shape = fallingShape else {
            return false
        }
        
        for bottomBlock in shape.bottomBlocks {
            if bottomBlock.row == NumRows - 1 || blockArray[bottomBlock.column, bottomBlock.row + 1] != nil {
                return true
            }
        }
        
        return false
    }
    
    func endGame() {
        score = 0
        level = 1
        delegate?.gameDidEnd(swiftris: self)
        
        
    }
    //fucntion that returns a tuple, composed of two arrays: linesRemoved and fallenBlocks, linesRemoved maintains each row of blocks which the user has filled in
    func removeCompletedLines() -> (linesRemoved: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>) {
        var removedLines = Array<Array<Block>>()
        //for loop iterates from 0 up to but not including NumColumns, 0 to 9. It adds every block in a given row to a local array variable named rowOfBlocks, if it equals 10 ie NumColumns then it counts that as a removed line and adds it to the return variable.
        for row in (1..<NumRows).reversed() {
            var rowOfBlocks = Array<Block>()
            // #11
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
            }
            if rowOfBlocks.count == NumColumns {
                removedLines.append(rowOfBlocks)
                for block in rowOfBlocks {
                    blockArray[block.column, block.row] = nil
                }
            }
        }
        
        // #12 check if we recovered lines at all, if not return empty arrays
        if removedLines.count == 0 {
            return ([], [])
        }
        // #13 add points to the player's score based on the number of lines theyve created and their level, if their points exceed exceed their level times 1000, they level up and we inform the delegate
        
        
        let pointsEarned = removedLines.count * PointsPerLine * level
        score += pointsEarned
        if score >= level * LevelThreshold {
            level += 1
            delegate?.gameDidLevelUp(swiftris: self)
        }
        
        var fallenBlocks = Array<Array<Block>>()
        for column in 0..<NumColumns {
            var fallenBlocksArray = Array<Block>()
            // #14 starting at the left-most column and above the bottom-most removed line, we count upwards towards the top of the game board, and we take each remaining block we find on the game board and lower it as far as possible, fallenblocks is an array of arrays, we have filled each sub-array with blocks that fell to a new position as a result of the user clearing lines beneath them
            for row in (1..<removedLines[0][0].row).reversed() {
                guard let block = blockArray[column, row] else {
                    continue
                }
                var newRow = row
                while (newRow < NumRows - 1 && blockArray[column, newRow + 1] == nil) {
                    newRow += 1
                }
                block.row = newRow
                blockArray[column, row] = nil
                blockArray[column, newRow] = block
                fallenBlocksArray.append(block)
            }
            if fallenBlocksArray.count > 0 {
                fallenBlocks.append(fallenBlocksArray)
            }
        }
        return (removedLines, fallenBlocks)
    }
    
    
    //This functions loops throught and creates a row of blocks in order for the game scene to animate them off the game board. Meanwhile, it nullifies each location in the block array to empty it entirely, preparing it for a new game
    func removeAllBlocks() -> Array<Array<Block>> {
    
        var allBlocks = Array<Array<Block>>()
        for row in 0..<NumRows {
            var rowOfBlocks = Array<Block>()
            for column in 0..<NumColumns {
                guard let block = blockArray[column, row] else {
                    continue
                }
                rowOfBlocks.append(block)
                blockArray[column,row] = nil
             }
             allBlocks.append(rowOfBlocks)
        }
        return allBlocks
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
