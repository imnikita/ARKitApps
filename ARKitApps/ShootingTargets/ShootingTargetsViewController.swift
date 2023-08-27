//
//  ShootingTargetsViewController.swift
//  RealText
//
//  Created by Mykyta Popov on 27/08/2023.
//

import UIKit
import SceneKit
import ARKit

enum BoxBodyType: Int {
    case bulet = 1
    case barrier
}

class ShootingTargetsViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    private var lastContactNode: SCNNode?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        let box1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.purple
        
        box1.materials = [material]
        
        let box1Node = SCNNode(geometry: box1)
        box1Node.name = "Barrier"
        box1Node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        box1Node.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        box1Node.position = SCNVector3(0, 0, -0.8)
        
        for j in 0...1 {
            let boxNode = box1Node.copy() as! SCNNode
            let geometry = box1Node.geometry?.copy() as! SCNGeometry?
            box1Node.geometry = geometry
            if j == 0 {
                boxNode.position.x = box1Node.position.x - 0.2
            } else {
                boxNode.position.x = box1Node.position.x + 0.2
                boxNode.position.y = box1Node.position.y + 0.4
                boxNode.position.z = box1Node.position.z - 0.1
            }
            boxNode.name = "Barrier\(String(j+1))"
            boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            boxNode.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
            scene.rootNode.addChildNode(boxNode)
        }
        
        scene.rootNode.addChildNode(box1Node)
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.scene.physicsWorld.contactDelegate = self
                
        registerGestures()
    }
    
    private func registerGestures() {
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(shoot))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func shoot(_ recognizer: UITapGestureRecognizer) {
        
        guard let currentFrame = sceneView.session.currentFrame else { fatalError() }
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.3
//        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        let sphere = SCNSphere(radius: 0.03)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "8k_earth_daymap")
        sphere.materials = [material]
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.name = "Bullet"
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        sphereNode.physicsBody?.categoryBitMask = BoxBodyType.bulet.rawValue
        sphereNode.physicsBody?.contactTestBitMask = BoxBodyType.barrier.rawValue
        sphereNode.physicsBody?.isAffectedByGravity = false
        sphereNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        let forceVector = SCNVector3(sphereNode.worldFront.x * 2,
                                     sphereNode.worldFront.y * 2,
                                     sphereNode.worldFront.z * 2)
        
        sphereNode.physicsBody?.applyForce(forceVector, asImpulse: true)
        sceneView.scene.rootNode.addChildNode(sphereNode)
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
}

extension ShootingTargetsViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        var contactedNode: SCNNode
        
        if contact.nodeA.name == "Bullet" {
            contactedNode = contact.nodeB
        } else {
            contactedNode = contact.nodeA
        }
        
        if lastContactNode != nil && contactedNode == lastContactNode { return }
        lastContactNode = contactedNode
        
        let material = SCNMaterial()
        material.diffuse.contents = randomColor()
        
        lastContactNode?.geometry?.materials = [material]
    }
}
