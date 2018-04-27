//
//  Shape.swift
//  Swiftris
//
//  Created by Restricted on 12/30/17.
//  Copyright © 2017 Bloc. All rights reserved.
//

import SpriteKit

//4 shapes
let NumOrientations: UInt32 = 4

//enum the shapes
enum Orientation: Int {
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String {
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    
    
    //function generates random shape from enum
    static func random() -> Orientation {
        return Orientation(rawValue: Int(arc4random_uniform(NumOrientations)))!
    }
    
// #1, method that returns the next orientation when traveling either clockwise or counterclockwise
    
    static func rotate(orientation: Orientation, clockwise: Bool) -> Orientation {
        
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        if rotated > Orientation.TwoSeventy.rawValue {
            rotated = Orientation.Zero.rawValue
        } else if rotated < 0 {
            rotated = Orientation.TwoSeventy.rawValue
        
        }
        return Orientation(rawValue: rotated)!
    }
}


//shape class definition

//the number of total shape varieties
let NumShapeTypes: UInt32 = 7

// Shape indexes

let FirstBlockIdx: Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx: Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, CustomStringConvertible {
    
    // the color of the shape
    
    let color:BlockColor
    
    // the blocks comprising the shape
    
    var blocks = Array<Block>()
    
    //var current orientation of the shape
    
    var orientation: Orientation
    
    // the column and row representing the shape's anchor point
    
    var column, row: Int
    
    // required overrides
//#2
    //subclasses must override this property
    //define a copmuted Dictionary, which is defined with square braces [...], used to map one object to another, the first object type listed defines the key and the second, a value, 1:1 mapping
    
    //return type is tuple
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [:]
    }
//3
    
    var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return[:]
    }
//4 computed property that returns the bottom blocks of the shape at its current orientation
    
    var bottomBlocks:Array<Block> {
        guard let bottomBlocks = bottomBlocksForOrientations[orientation] else {
            return []
        }
        return bottomBlocks
    }
    
    //hashable, uses reduce method to iterate through our entire blocks array, XOR each blocks hashValue together to create a single hash value
    
    var hashValue: Int  {
        return blocks.reduce(0) { $0.hashValue ^ $1.hashValue}
        
    }
    
    // CustomStringConvertible
    
    var description: String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    
    
    
    //that initializer tho
    
    init(column: Int, row: Int, color: BlockColor, orientation: Orientation) {
        self.color = color
        self.column = column
        self.row = row
        self.orientation = orientation
        
        initializeBlocks()
    }
    
// #6
    
    convenience init(column: Int, row:Int) {
        self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
    }
    
// #7 final function can not be overwritten by subclasses
    
    final func initializeBlocks() {
        guard let blockRowColumnTranslations = blockRowColumnPositions[orientation] else {
            return
        }
    
    
// 8, map method creates Blocks array, map executes the provided code block for each object found in the array  and returns a Block object. map adds each Block returned to the blocks array. map lets us create one array after looping over the contents of another
    
        blocks = blockRowColumnTranslations.map{ (diff) -> Block in
            return Block(column:column + diff.columnDiff, row:row + diff.rowDiff, color: color)
        }
    }
    
    // helper functions that establish and alter shapes location
    final func rotateBlocks(orientation: Orientation) {
        guard let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] else {
            return
        }
// #1: iterate through object array using two index variables diff for reference to column and row difference
        for (idx, diff) in blockRowColumnTranslation.enumerated() {
            blocks[idx].column = column + diff.columnDiff
            blocks[idx].row = row + diff.rowDiff
        }
    }
 
    
// #3
    final func rotateClockwise() {
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: true)
        rotateBlocks(orientation: newOrientation)
        orientation = newOrientation
    
    }
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation: orientation, clockwise: false)
        rotateBlocks(orientation: newOrientation)
        orientation = newOrientation
    }
    
    final func raiseShapeByOneRow() {
        shiftBy(columns: 0, rows: -1)
    }

    
    
    final func lowerShapeByOneRow() {
        shiftBy(columns: 0, rows: 1)
        
    }
    
    final func shiftRightByOneColumn() {
        shiftBy(columns: 1, rows: 0)
    }
   
    
    final func shiftLeftByOneColumn() {
        
        shiftBy(columns: -1, rows: 0)
        
        
    }
    
   
// #2: adjust each row and column by rows and columns respectively
    final func shiftBy(columns: Int, rows: Int) {
        self.column += columns
        self.row += rows
        
        for block in blocks {
        block.column += columns
        block.row += rows
        
        }
    }
// #3 set the column and row to their respective orientation in order to accurate realign all blocks relative to the new row and column properties
    final func moveTo(column: Int, row:Int) {
        self.column = column
        self.row = row
        
        rotateBlocks(orientation: orientation)
    }
    
    //randomly select pieces to fall
    final class func random (startingColumn: Int, startingRow: Int) -> Shape {
        switch Int(arc4random_uniform(NumShapeTypes)) {
// #4
        case 0:
            return SquareShape(column: startingColumn, row: startingRow)
        case 1:
            return LineShape(column: startingColumn, row: startingRow)
        case 2:
            return TShape(column: startingColumn, row: startingRow)
        case 3:
            return LShape(column: startingColumn, row: startingRow)
        case 4:
            return JShape(column: startingColumn, row: startingRow)
        case 5:
            return SShape(column: startingColumn, row: startingRow)
        default:
            return ZShape(column: startingColumn, row: startingRow)
        }
    }
    
    
    
    
    
    
    
    
    
}

func ==(lhs: Shape, rhs: Shape) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}



















































