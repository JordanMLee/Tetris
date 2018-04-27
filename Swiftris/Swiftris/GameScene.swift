//
//  GameScene.swift
//  Swiftris
//
//  Created by Restricted on 12/25/17.
//  Copyright © 2017 Bloc. All rights reserved.
//

import SpriteKit

// #1 TickLengthLevelOne represents the slowest speed at which out shapes will travel
//set to 600ms

// #7 constant for visuals
//define the point size of each block sprite 20x20, the lower of the available resolution options for each block image

let BlockSize:CGFloat = 20.0

let TickLengthLevelOne = TimeInterval(600)


class GameScene: SKScene {
// 8 visuals
    
// declare a layer position which will offset from edge of the screen
// SKNodes act as superimposed layers of activity within our scene, the gameLayer sits above the background visuals and the shapeLayer sits atop of that
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    let LayerPosition = CGPoint(x: 6, y: -6)
    
// #2
    
    //tick is closure that takes no parameters and returns nothing, optional
    var tick:(() -> ())?
    
    //GameScene's current tick length set to 600ms by default
    var tickLengthMillis = TickLengthLevelOne
    
    //tracks  the last time we experience a tick (NSDate)
    var lastTick:NSDate?

// #8
    var textureCache = Dictionary<String, SKTexture>()
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        //create an SKSpriteNode capable of representing out background image
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0) //bottom-left corner
        background.anchorPoint = CGPoint(x: 0, y: 1.0) //drawing anchored to the top left corner of screen
        addChild(background) //add it to scene
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard")
        //note CGMakeSize no longer works with Swift
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSize(width:(BlockSize * CGFloat(NumColumns)), height:(BlockSize * CGFloat(NumRows))))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
// #3
     //guard statement checks the conditions which follows it, if it fails, else is executed
        //if lastTick is missing game is paused
        guard let lastTick = lastTick else {
            return
        }
        
        //otherwise continue with updated time
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        
        if timePassed > tickLengthMillis {
            self.lastTick = NSDate()
            
            tick?()
        }
    }
    
// #4 accessor method to let external classes stop and start the ticking process 
    
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
// #9
    
    //important function, returns the precise coordinate on the screen for where a block sprite belongs based on its row and column position. each sprite is anchored at its center, so center coordinates need to be determined before placing it in our shapeLayer object
   
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        
        return CGPoint(x: x,y: y)
        
    }
    
//method will add a shape for the first time to scene as a preview shape, SKTexture objects are stored in a dictionary because each shape will require more than one copy of the same image
    func addPreviewShapeToScene(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
// #10
            var texture = textureCache[block.spriteName]
            if texture == nil {
                
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            
            let sprite = SKSpriteNode(texture: texture)
// #20
//pointsforColumn method places each block's sprite in the proper location starting at row -2, so that the preview piece animates smoothly into place from a high location
            sprite.position = pointForColumn(column:block.column , row:block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            //Animation
            sprite.alpha = 0
// #12
//  SKAction objects visually manipulate SKNode objects, each block will fade and move into place as it appears as part of the next piece, it will move two rows down and fade from copmlete transparency to 70% opacity
            // this allows the player to ignore the preview piece since it will be duller than the active moving piece,
            
            
            let moveAction = SKAction.move(to: pointForColumn(column: block.column, row: block.row), duration: TimeInterval(0.2))
            moveAction.timingMode = .easeOut
            
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            fadeInAction.timingMode = .easeOut
            
            sprite.run(SKAction.group([moveAction, fadeInAction]))
        }
        
        run(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    //move and redraw each block for a given shape
    func movePreviewShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row: block.row)
            let moveToAction: SKAction = SKAction.move(to: moveTo, duration: 0.05)
            
            moveToAction.timingMode = .easeOut
            
            sprite.run(SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]),completion: {})
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func redrawShape(shape: Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            
            let moveTo = pointForColumn(column: block.column, row: block.row)
            
            let moveToAction = SKAction.move(to: moveTo, duration: 0.05)
            
            moveToAction.timingMode = .easeOut
            
    
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
                
            } else {
                sprite.run(moveToAction)
                
            }
        }
    }
    
}


