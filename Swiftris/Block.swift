//
//  Block.swift
//  Swiftris
//
//  Created by Restricted on 12/30/17.
//  Copyright © 2017 Bloc. All rights reserved.
//

import SpriteKit

// define number of colors (6)

let NumberOfColors: UInt32 = 6

// enum the six colors

enum BlockColor: Int, CustomStringConvertible {
// #3
    
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
// computed property is one that behaves like a typical var but when accessing it, a code block 
    //generates its value each time
    
    var spriteName: String {
        switch self {
            
        case .Blue:
            return "blue"
            
        case .Orange:
            return "orange"
        
        case .Purple:
            
            return "purple"
        
        case .Red:
            return "red"
            
        case .Teal:
            return "teal"
            
        case .Yellow:
            return "yellow"
            
        }
    }
// #5
    
    var description: String{
        return self.spriteName
    }
    
// randomize the colors of blocks generated.
    
    static func random() -> BlockColor {
        return BlockColor(rawValue: Int(arc4random_uniform(NumberOfColors)))!
    }
    
}

// Declare Block class, hashable superclass allows us to store Block in Array2D

class Block: Hashable, CustomStringConvertible {
//#8, once we assign color to block it can not be changed
    
    // Constants
    let color: BlockColor
//#9,represent the location of the Block on our game board, The SKSpriteNode will represent the visual element of the Block which  GameScene will use to render and animate the Block
    
    //Properties
    
    var column: Int
    var row:Int
    var sprite: SKSpriteNode?
    
// #10, convenient shortcut for recovering the sprite's file name,
    //Computed Properties
    
    var spriteName: String {
        return color.spriteName
    }
// #11, implement hashValue calculated property, which Hashable requires, returns the XOR of row and column
    var hashValue: Int{
        return self.column ^ self.row
    }
// #12, description implementation required by CustomStringConvertible
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column: Int, row: Int, color: BlockColor) {
        self.column = column
        self.row = row
        self.color = color
        
    }
}


// #13, created a custom operator '==', when comparing one Block with another, it returns true if both blocks are in the same location and of the same color, The Hashable protocol inherits from the Equatable protocol, which requires us to provide this operator

func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}



















































