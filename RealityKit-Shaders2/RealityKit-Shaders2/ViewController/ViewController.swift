//
//  ViewController.swift
//  RealityKit-Shaders2
//
//  Created by Artyom Mihailovich on 10/4/21.
//

import UIKit
import RealityKit

final class ViewController: UIViewController {
    
    private lazy var arView = ARView().do {
        $0.frame = view.bounds
    }
    
    private var entity: ModelEntity!
    private let anchor = AnchorEntity(plane: .horizontal)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubview()
        obtainSphereEntity()
    }
    
    private func setupSubview() {
        view.addSubview(arView)
    }
    
    private func obtainSphereEntity() {
        let mtlLibrary = MTLCreateSystemDefaultDevice()!.makeDefaultLibrary()!
        let surfaceShader = CustomMaterial.SurfaceShader(named: "surfaceShader", in: mtlLibrary)
        let material = PhysicallyBasedMaterial()
        
        entity = ModelEntity(mesh: .generateSphere(radius: 0.3),
                             materials: [material])
        
        entity.model?.materials = entity.model?.materials.map {
            try! CustomMaterial(from: $0, surfaceShader: surfaceShader)
        } ?? [Material]()
        
        entity.generateCollisionShapes(recursive: true)
        entity.setParent(anchor)
        
        entity.position.y = 0.6
        
        arView.installGestures(.all, for: entity)
        arView.scene.anchors.append(anchor)
    }
}
