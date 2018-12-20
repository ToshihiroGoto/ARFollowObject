//
//  ViewController.swift
//  ARFollowObject
//
//  Created by Toshihiro Goto on 2018/12/20.
//  Copyright © 2018 Toshihiro Goto. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var nodeDic:Dictionary<String, simd_float4x4> = [:]
    
    private var fixedFlag:Bool = true
    
    // Action: UISwitch
    @IBAction func switchFixedPosition(_ sender: UISwitch) {
        if sender.isOn {
            fixedFlag = true
        }else {
            fixedFlag = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "main.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result: AnyObject = hitResults[0]
            
            // get AR Camera Node
            let cameraNode = sceneView.pointOfView!
            
            let followGeometryNode = result.node! as SCNNode
            let followNode = followGeometryNode.parent!
            let nodeName = followNode.name!
            let nodeInfo = nodeDic[nodeName]
            
            if (nodeInfo != nil) {
                
                sceneView.scene.rootNode.addChildNode(followNode)
                
                if(fixedFlag != false){
                    followNode.simdWorldTransform = nodeDic[nodeName]!
                }else{
                    followNode.simdTransform = cameraNode.simdConvertTransform(followNode.simdTransform, to: nil)
                    followNode.simdEulerAngles = simd_float3()
                }
                
                nodeDic[nodeName] = nil
            } else {
                // Save Node Position
                nodeDic[nodeName] = followNode.simdWorldTransform
                
                cameraNode.addChildNode(followNode)
                
                followNode.simdTransform = cameraNode.simdConvertTransform(followNode.simdTransform, from: nil)
            }
            
            // get its material
            let material = followGeometryNode.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            if(nodeInfo != nil){
                material.emission.contents = UIColor.white
            }else{
                material.emission.contents = UIColor.red
            }
            
            SCNTransaction.commit()
        }
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
