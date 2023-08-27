//
//  MeasurementViewController.swift
//  ARKitApps
//
//  Created by Mykyta Popov on 27/08/2023.
//

import UIKit
import SceneKit
import ARKit

class MeasurementViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var spheres = [SCNNode]()
    private var distanceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        label.backgroundColor = .green
        label.textAlignment = .center
        label.textColor = .red
        label.font = .systemFont(ofSize: 30)
        label.text = "0.0"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addDistanceLabel()
        addCross()
        registerGestures()
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
    
    private func addCross() {
        let lable = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 33))
        lable.text = "+"
        lable.textAlignment = .center
        lable.textColor = .red
        lable.font = .systemFont(ofSize: 30)
        lable.center = sceneView.center
        sceneView.addSubview(lable)
    }
    
    private func addDistanceLabel() {
        sceneView.addSubview(distanceLabel)
        
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.centerXAnchor.constraint(equalTo: sceneView.centerXAnchor).isActive = true
        distanceLabel.centerYAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
    }
    
    private func registerGestures() {
        let gestureRecognizer = UITapGestureRecognizer(target: self,
                                                       action: #selector(didTap))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didTap(_ recognizer: UITapGestureRecognizer) {
        guard let sceneView = recognizer.view as? ARSCNView else { return }
        let touchLocation = self.sceneView.center
        
        let hitTestResults = sceneView.hitTest(touchLocation,
                                               types: .featurePoint)
        
        guard !hitTestResults.isEmpty, let result = hitTestResults.first else {
            return
        }
        
        let sphere = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        
        sphere.firstMaterial = material
        
        let sphereNode = SCNNode(geometry: sphere)
        
        let realWorldPoints = result.worldTransform.columns
        
        sphereNode.position = SCNVector3(realWorldPoints.3.x,
                                         realWorldPoints.3.y,
                                         realWorldPoints.3.z)
        
        self.sceneView.scene.rootNode.addChildNode(sphereNode)
        spheres.append(sphereNode)
        
        if spheres.count >= 2 {
            calculateTotalDistanceBetweenNodes(spheres)
        }
    }
    
    private func calculateTotalDistanceBetweenNodes(_ nodes: [SCNNode]) {
        guard nodes.count >= 2 else { return }

        var totalDistance: Double = 0.0

        for i in 0..<(nodes.count - 1) {
            let node1 = nodes[i]
            let node2 = nodes[i + 1]

            // Calculate the distance between node1 and node2
            let position1 = node1.presentation.worldPosition
            let position2 = node2.presentation.worldPosition
            let deltaX = position2.x - position1.x
            let deltaY = position2.y - position1.y
            let deltaZ = position2.z - position1.z

            var distance = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)

            // Add the distance to the total
            totalDistance += Double(distance)
            
            distanceLabel.text = String(totalDistance)
        }
    }
}
