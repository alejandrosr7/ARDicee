//
//  ViewController.swift
//  ARDicee
//
//  Created by Alejandro Serna Rodriguez on 2/12/20.
//  Copyright © 2020 Alejandro Serna Rodriguez. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        The moon
//        let sphere = SCNSphere(radius: 0.2)
//
//        let material = SCNMaterial()
//
//        material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
//        sphere.materials = [material]
//
//        let node = SCNNode()
//
//        node.position = SCNVector3(0, 0.1, -0.5) /* Create the position of the element */
//
//        node.geometry = sphere
//
//        sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
//        // Create a new scene dice
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.dae")!
//
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//
//            diceNode.position = SCNVector3(0, 0, -0.1)
//            sceneView.scene.rootNode.addChildNode(diceNode)
//        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if ARWorldTrackingConfiguration.isSupported {
            // Create a session configuration
            let configuration = ARWorldTrackingConfiguration()

            configuration.planeDetection = .horizontal

            // Run the view's session
            sceneView.session.run(configuration)
        } else {
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }

    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }

//MARK: - Dice Rendering Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let toucheLocation = touch.location(in: sceneView)

            let results =  sceneView.hitTest(toucheLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                addDice(atLocation: hitResult)
            }
        }
    }

    func addDice(atLocation location: ARHitTestResult) {
        // Create a new scene dice
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.dae")!
        
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            
            diceNode.position = SCNVector3(location.worldTransform.columns.3.x, location.worldTransform.columns.3.y + diceNode.boundingSphere.radius, location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }

    func roll(dice: SCNNode) {
        let randomX = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        let randomZ = Float((arc4random_uniform(4) + 1)) * (Float.pi/2)
        
        dice.runAction(SCNAction.rotateBy(x: CGFloat(randomX * 10), y: 0, z: CGFloat(randomZ * 10), duration: 0.5))
    }

    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }

//MARK: - ARSCNViewDelegateMethods

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        guard let planeAncor = anchor as? ARPlaneAnchor else {
            return
        }

        let planeNode = createPlane(withPlaneAnchor: planeAncor)

        node.addChildNode(planeNode)
    }

//MARK: - Plane Rendering Methods

    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(CGFloat(planeAnchor.center.x), 0, CGFloat(planeAnchor.center.z))

        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)

        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")

        plane.materials = [gridMaterial]

        planeNode.geometry = plane
        
        return planeNode
    }
}
