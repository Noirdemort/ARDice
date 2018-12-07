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
//        let node = SCNNode()
//        node.geometry = SCNSphere(radius: 0.1)
//        node.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/2k_uranus.jpg")
//        node.position = SCNVector3(0.1, 0.1, 0)
        
//        sceneView.scene.rootNode.addChildNode(node)
        // Create a new scene
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//        let diceNode =  diceScene.rootNode.childNode(withName: "Dice", recursively: true)
//        diceNode?.position = SCNVector3(0, 0.1, -0.1)
//        sceneView.scene.rootNode.addChildNode(diceNode!)
//        // Set the scene to the view
        
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
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")
                let hitResult = results.first
                let diceNode = diceScene?.rootNode.childNode(withName: "Dice", recursively: true)
                diceNode?.position = SCNVector3((hitResult?.worldTransform.columns.3.x)!, (hitResult?.worldTransform.columns.3.y)! + (diceNode?.boundingSphere.radius)!, (hitResult?.worldTransform.columns.3.z)!)
                diceArray.append(diceNode!)
                sceneView.scene.rootNode.addChildNode(diceNode!)
                let randomX = Float(arc4random_uniform(4) + 1)*Float.pi/2
                let randomZ = Float(arc4random_uniform(4) + 1)*Float.pi/2
                diceNode?.runAction(SCNAction.rotateBy(x: CGFloat(randomX*5), y: 0, z: CGFloat(randomZ*5), duration: 0.5))
            } else {
                print("Touches missed from plane")
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            print("plane detected")
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x : planeAnchor.center.x, y:0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/stillness_solitude.jpg")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
        } else { return }
    }

    func rollAll(){
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
        
    }
    
    func roll(dice : SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1)*Float.pi/2
        let randomZ = Float(arc4random_uniform(4) + 1)*Float.pi/2
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX*5), y: 0, z: CGFloat(randomZ*5), duration: 0.5))
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
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
