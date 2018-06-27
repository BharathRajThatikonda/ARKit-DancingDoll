//
//  ViewController.swift
//  ARSambaDance
//
//  Created by Guest1 on 08/11/17.
//  Copyright © 2017 Bharath Thatikonda. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ReplayKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var bombSoundEffect: AVAudioPlayer?

    let recording = RPScreenRecorder.shared()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        ///Users/guest1/Desktop/ARKIT-Bharath/ARSambaDance/Champion - Dwayne DJ Bravo.mp3
        // Set the scene to the view
        //∫   recording.delegate = self as? RPScreenRecorderDelegate
        sceneView.scene = scene
        let path = Bundle.main.path(forResource: "Champion - Dwayne DJ Bravo.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            bombSoundEffect = try AVAudioPlayer(contentsOf: url)
            bombSoundEffect?.prepareToPlay()
            bombSoundEffect?.play()
        } catch {
            // couldn't load file :(
        }
        loadAnimation()
        
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
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
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
    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: anchor.center.x, y: 0, z: anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        return planeNode
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Remove existing plane nodes
        node.enumerateChildNodes {
            (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        
        let planeNode = createPlaneNode(anchor: planeAnchor)
        
        node.addChildNode(planeNode)
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode12 = createPlaneNode(anchor: planeAnchor)
        
        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode12)}
    func loadAnimation(){
        let characterScene = SCNScene(named: "art.scnassets/Sambadance.dae")!
        let parentNode = SCNNode()
        for child in characterScene.rootNode.childNodes {
            parentNode.addChildNode(child)
        }
        parentNode.position = SCNVector3(0, -1, -3)
        parentNode.scale = SCNVector3(0.007, 0.007, 0.007)
        sceneView.scene.rootNode.addChildNode(parentNode)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first {
                let characterScene = SCNScene(named: "art.scnassets/dance.dae")!
                let parentNode = SCNNode()
                for child in characterScene.rootNode.childNodes {
                    parentNode.addChildNode(child)
                }
                parentNode.position = SCNVector3(0, -1, -2)
                parentNode.position = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y , z: hitResult.worldTransform.columns.3.z)
                parentNode.scale = SCNVector3(0.006, 0.006, 0.006)
             sceneView.scene.rootNode.addChildNode(parentNode)
               
                
                
            }
            
        }
    }
    @IBAction func TakeImage(_ sender: Any) {
        let screenShot = sceneView.snapshot()
        print(screenShot)
        UIImageWriteToSavedPhotosAlbum(screenShot, nil, nil, nil)
    }

    @IBAction func stoprecording(_ sender: Any) {
        
        recording.stopRecording { (preiewVC, error) in
            
            if let previewVC = preiewVC {
                previewVC.previewControllerDelegate = self
                self.present(previewVC, animated: true, completion: nil)
            }
            
            if let error = error{
                print(error)
            }
        }
    }
    
    @IBOutlet weak var startRecording: UIButton!
    
    @IBAction func startRecod(_ sender: Any) {
        
        guard recording.isAvailable else{
            print("not available")
            return
        }
        
        recording.startRecording { (error) in
            if let error = error{
                print(error)
            }
        }
    }
    

}
extension ViewController:RPPreviewViewControllerDelegate {
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true, completion: nil)
    }
}

