//
//  ViewController.swift
//  ARKitStartApp
//
//  Created by Artyom Mihailovich on 3/9/21.
//

import UIKit
import RealityKit
import ARKit
import SnapKit

final class ViewController: UIViewController {
    
    lazy private var arView = ARView().do {
        $0.cameraMode = .ar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubview()
        addBox()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        implementPersonSegmentation()
    }
    
    private func setupSubview() {
        view.addSubview(arView)
        
        arView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func addBox() {
        let boxAnchor = try! Experience.loadBox()
        boxAnchor.generateCollisionShapes(recursive: true)
        let steelBox = boxAnchor.steelBox as? Entity & HasCollision
        arView.installGestures([.all], for: steelBox!)
        arView.scene.anchors.append(boxAnchor)
    }
    
    private func implementPersonSegmentation() {
        guard let configuration = arView.session.configuration as? ARWorldTrackingConfiguration else {
            fatalError("DEBUG: - Unexpectedly failed to get the configuration.")
        }
        
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("DEBUG: - People occlusion is not supported on this device.")
        }
        
        configuration.frameSemantics.insert(.personSegmentationWithDepth)
        arView.session.run(configuration)
    }
}
