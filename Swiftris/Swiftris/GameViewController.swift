//
//  GameViewController.swift
//  Swiftris
//
//  Created by Restricted on 12/25/17.
//  Copyright © 2017 Bloc. All rights reserved.
//

import UIKit
import SpriteKit


class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {
    
    var scene: GameScene! //instantiate GameScene object
    var swiftris:Swiftris! //instantiate Swiftris object
    
    var panPointReference:CGPoint?  //last point on the screen at which a shape movement occured or where a pan begins
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        
        let skView = view as! SKView // as! operator is a forced downcast from UIView to SKView
        
        skView.isMultipleTouchEnabled = false
        
        //Create and configure the scene
        
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill //tell scene to fill the screen
        
        // #13
        scene.tick = didTick
        
        swiftris = Swiftris()
        swiftris.delegate = self
        swiftris.beginGame()
        
        // Present the scene to user
        
        skView.presentScene(scene)
        
      // 14
        /*
        scene.addPreviewShapeToScene(shape: swiftris.nextShape!) {
            self.swiftris.nextShape?.moveTo(column: StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(shape: self.swiftris.nextShape!) {
                let nextShapes = self.swiftris.newShape()
                
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(shape: nextShapes.nextShape!) {}
                
            
        }
        
        
        }*/
        
        
        
        
    }

   
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        //recover  apoint which defines the translation of the gesture relative to where it began, this is not an absolute coordinate, just a measure of the distance that the user's finger has traveled
        let currentPoint = sender.translation(in: self.view)
        if let originalPoint = panPointReference {
            
            //chceck
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }

    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        
        swiftris.rotateShape()
        
    }
    //#15 function the alowers the falling shape by one row and then asks Gamescene to redraw the shape at its new location
    
    func didTick() {
        
        swiftris.letShapeFall()
        
        //swiftris.fallingShape?.lowerShapeByOneRow()
        
        //scene.redrawShape(shape: swiftris.fallingShape!, completion: {})
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
        self.scene.movePreviewShape(shape: fallingShape) {
        
        //
        
        self.view.isUserInteractionEnabled = true
        
        self.scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        // The following is false when restarting the game
        
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.isUserInteractionEnabled = false
        scene.stopTicking()
    }
    
    func gameDidLevelUp(swiftris: Swiftris) {
        
        
    }
    
    func gameShapeDidDrop(swiftris: Swiftris) {
        
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        nextShape()
    }
    
    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(shape: swiftris.fallingShape!) {}
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
