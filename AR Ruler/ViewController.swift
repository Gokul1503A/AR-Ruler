//
//  ViewController.swift
//  AR Ruler
//
//  Created by KOPPOLA GOKUL SAI on 01/01/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes{
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView){
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .estimatedPlane, alignment: .any){
                let results = sceneView.session.raycast(query)
                if let rayResult = results.first {
                    addDot(at: rayResult)
                }
            }
        }
    }
    
    func addDot(at rayResult: ARRaycastResult){
        let dotGeometry  = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(x: rayResult.worldTransform.columns.3.x,
                                      y: rayResult.worldTransform.columns.3.y,
                                      z: rayResult.worldTransform.columns.3.z
        )
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        
        if dotNodes.count >= 2{
            calculate()
        }
        
    }
    
    func calculate(){
        
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        let a = start.position.x - end.position.x
        let b = start.position.x - end.position.y
        let c = start.position.z - end.position.z
        
        let distance = sqrt(pow(a, 2) + pow(b,2) + pow(c,2))
        
        update(text: String(distance), position: end.position)
    }
    
    func update(text: String, position: SCNVector3){
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode.geometry = textGeometry 
        textNode.position = SCNVector3(position.x, position.y+0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }

    
}
