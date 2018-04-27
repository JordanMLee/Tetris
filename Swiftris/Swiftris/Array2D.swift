//
//  Array2D.swift
//  Swiftris
//
//  Created by Restricted on 12/30/17.
//  Copyright © 2017 Bloc. All rights reserved.
//
/*
// #1 class definition

//notes: generic arrays in Swift are of type struct, you can class objects by reference but
//you must pass structures by value
//<T> allows array to store any data type

class Array2D<T> {
    let columns: Int
    let rows: Int
    
// #2 declare swift array (optional)
//if nil, then location found on game board will be empty with no block
    
    var array: Array<T?>
    
    // Proper initialization required
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
// #3  instantiate internal array structure with size rows*columns
        
        array = Array<T?>(repeating: nil, count: rows * columns)
        
    }
    
// #4 setter and getter
    
//getter: gets the value at a given location and returns the product of rows*columns
//setter: sets newValue to the location determined by the same
    subscript(column: Int, row: Int) -> T? {
        get{
            return array[(rows * columns) + column]
        }
        
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
    }
    
}
*/

//
//  Array2D.swift
//  Swiftris
//
//  Created by Stan Idesis on 7/17/14.
//  Copyright (c) 2014 Bloc. All rights reserved.
//
class Array2D<T> {
    let columns: Int
    let rows: Int
    var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(repeating: nil, count:rows * columns)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + column]
        }
        set(newValue) {
            array[(row * columns) + column] = newValue
        }
}
}

