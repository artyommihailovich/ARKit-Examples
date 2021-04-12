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
    
    private var robotAnchor: Experience.Robot!
    private var occlusionEntity: Entity!
    
    private var isActive = false
    
    lazy private var arView = ARView().do {
        $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(occlusionMaterialDidTapped)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubview()
        obtainRobotScene()
        obtainOcclusionMaterial()
    }
    
    private func setupSubview() {
        view.addSubview(arView)
        
        arView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func obtainRobotScene() {
        do {
            robotAnchor = try Experience.loadRobot()
            robotAnchor.generateCollisionShapes(recursive: true)
        } catch {
            print("DEBUGER: - Error loaded Robot scene.")
        }
        
        let steelRobot = robotAnchor.steelRobot as? Entity & HasCollision
        arView.installGestures([.all], for: steelRobot!)
        arView.scene.anchors.append(robotAnchor)
    }
    
    private func obtainOcclusionMaterial() {
        let occlusionMaterial = OcclusionMaterial()
        occlusionEntity = ModelEntity(mesh: .generateBox(width: 0.2, height: 0.2, depth: 0.01), materials: [occlusionMaterial])
        occlusionEntity.generateCollisionShapes(recursive: true)
        robotAnchor.addChild(occlusionEntity)
        arView.installGestures([.all], for: occlusionEntity as! HasCollision)
    }
    
    @objc
    private func occlusionMaterialDidTapped(tapGesture: UITapGestureRecognizer) {
        tapGesture.numberOfTapsRequired = 2
        tapGesture.addTarget(self, action: #selector(tapGestureDidTap))
    }
    
    @objc
    private func tapGestureDidTap() {
        switch isActive {
        case true:
            arView.debugOptions = [.showPhysics, .showAnchorOrigins]
            isActive = false
        case false:
            arView.debugOptions = [.none]
            isActive = true
        }
    }
}
