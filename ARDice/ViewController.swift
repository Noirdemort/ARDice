//
//  ViewController.swift
//  ARDice
//
//  Created by Noirdemort on 07/11/18.
//  Copyright © 2018 Noirdemort. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true

        sceneView.automaticallyUpdatesLighting = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if !results.isEmpty {
                let hitResult = results.first
                addDice(atLocation: hitResult!)
            } else {
                print("Touches missed from plane")
            }
        }
    }
    
    
    func addDice(atLocation location: ARHitTestResult){
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
        let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true)
        diceNode?.position = SCNVector3((location.worldTransform.columns.3.x), (location.worldTransform.columns.3.y) + (diceNode?.boundingSphere.radius)!, (location.worldTransform.columns.3.z))
        diceArray.append(diceNode!)
        sceneView.scene.rootNode.addChildNode(diceNode!)
        let randomX = Float(arc4random_uniform(4) + 1)*Float.pi/2
        let randomZ = Float(arc4random_uniform(4) + 1)*Float.pi/2
        diceNode?.runAction(SCNAction.rotateBy(x: CGFloat(randomX*5), y: 0, z: CGFloat(randomZ*5), duration: 0.5))
    }
    

    func roll(dice : SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1)*Float.pi/2
        let randomZ = Float(arc4random_uniform(4) + 1)*Float.pi/2
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX*5), y: 0, z: CGFloat(randomZ*5), duration: 0.5))
    }
    
    
    func rollAll(){
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    @IBAction func clearBoard(_ sender: Any) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    
    // MARK: - ARSCNViewDelegate

     func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        node.addChildNode(planeNode)
     }
    
    func createPlane(withPlaneAnchor planeAnchor : ARPlaneAnchor) -> SCNNode{
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/stillness_solitude.jpg")
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        plane.materials = [gridMaterial]
       
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x : planeAnchor.center.x, y:0, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        planeNode.geometry = plane
        
        return planeNode
    }

}
