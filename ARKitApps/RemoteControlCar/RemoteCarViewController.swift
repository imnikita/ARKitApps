//
//  RemoteCarViewController.swift
//  ARKitApps
//
//  Created by Mykyta Popov on 27/08/2023.
//

import UIKit
import SceneKit
import ARKit

class RemoteCarViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planes = [OverlayPlane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
//        sceneView.autoenablesDefaultLighting = true
        
        let carScene = SCNScene(named: "car.dae")
        let carNode = carScene?.rootNode.childNode(withName: "car",
                                                   recursively: true)
        
        
        // Create a new scene
        let scene = SCNScene()
        if let carNode = carNode {
            carNode.position = SCNVector3(0, 0, -1)
            scene.rootNode.addChildNode(carNode)
        }
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addTapGesture()
        setupGamepad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func setupGamepad() {
        let leftButton = UIButton(frame: CGRect(x: 0,
                                                y: sceneView.frame.height - 50,
                                                width: 50,
                                                height: 50))
        leftButton.setTitle("Left", for: .normal)
        
        
        let rightButton = UIButton(frame: CGRect(x: 70,
                                                 y: sceneView.frame.height - 50,
                                                 width: 50,
                                                 height: 50))
        rightButton.setTitle("Right", for: .normal)
        
        let acceleratorButton = UIButton(frame: CGRect(x: sceneView.frame.width - 100,
                                                       y: sceneView.frame.height - 70,
                                                       width: 60,
                                                       height: 60))

        acceleratorButton.backgroundColor = .red
        acceleratorButton.layer.cornerRadius = 10
        acceleratorButton.layer.masksToBounds = true
        acceleratorButton.setTitle("Go!", for: .normal)
        
        sceneView.addSubview(acceleratorButton)
        sceneView.addSubview(leftButton)
        sceneView.addSubview(rightButton)
    }
    
    private func addTapGesture() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }

    
    @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)

    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if !(anchor is ARPlaneAnchor) {
            return
        }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }
}
