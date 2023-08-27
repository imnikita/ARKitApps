//
//  DetectingPlanesViewController.swift
//  RealText
//
//  Created by Mykyta Popov on 25/08/2023.
//

import UIKit
import SceneKit
import ARKit

class DetectingPlanesViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    private var lable: UILabel = {
        let lable = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        lable.textColor = .white
        lable.font = UIFont.systemFont(ofSize: 20)
        
        return lable
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lable.center = self.sceneView.center
        lable.alpha = 0
        sceneView.addSubview(lable)
        
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
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
    
    func renderer(_ renderer: SCNSceneRenderer,
                  didAdd node: SCNNode,
                  for anchor: ARAnchor) {
        DispatchQueue.main.async {
            self.lable.text = "Plane is detected"
            
            UIView.animate(withDuration: 3.0) { [weak self] in
                self?.lable.alpha = 1
            } completion: { [weak self] _ in
                self?.lable.alpha = 0
            }
        }
    }
}
