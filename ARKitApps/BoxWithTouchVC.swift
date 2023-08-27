//
//  BoxWithTouchVC.swift
//  RealText
//
//  Created by Mykyta Popov on 23/08/2023.
//

import UIKit
import SceneKit
import ARKit

class BoxWithTouchVC: UIViewController, ARSCNViewDelegate {

	@IBOutlet var sceneView: ARSCNView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set the view's delegate
		sceneView.delegate = self
		
		// Show statistics such as fps and timing information
		sceneView.showsStatistics = true
		
		// Create a new scene
		let scene = SCNScene()
		
		// Set the scene to the view
		sceneView.scene = scene
		
//		let text = SCNText()
		
		let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0)
		
		let material = SCNMaterial()
        material.name = "Color"
        material.diffuse.contents = UIColor.red
		
		let boxNode = SCNNode(geometry: box)
		boxNode.position = SCNVector3(0, 0, -1)
		boxNode.geometry?.materials = [material]

		sceneView.scene.rootNode.addChildNode(boxNode)
		
		let tapGesture = UITapGestureRecognizer(target: self,
												action: #selector(tapped))
		sceneView.addGestureRecognizer(tapGesture)
	}
	
	@objc private func tapped(_ recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! SCNView
        let touchLocation = recognizer.location(in: sceneView)
        let hitResult = sceneView.hitTest(touchLocation)
        
        if !hitResult.isEmpty {
            let node = hitResult[0].node
            let material = node.geometry?.material(named: "Color")
            
            material?.diffuse.contents = UIColor.green
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
}


