//
//  ViewController.swift
//  RealityKit-Shaders
//
//  Created by Artyom Mihailovich on 6/15/21.
//

import UIKit
import ARKit
import RealityKit
import RealityGeometries

final class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView! {
        didSet {
            arView.configureARSession()
        }
    }
    
    private var entity: ModelEntity!
    private let anchor = AnchorEntity(plane: .horizontal)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        obtainPlaneEntity()
    }
    
    private func obtainPlaneEntity() {
        let mtlLibrary = MTLCreateSystemDefaultDevice()!.makeDefaultLibrary()!
        let geometryModifier = CustomMaterial.GeometryModifier(named: "waveMotion", in: mtlLibrary)
        let surfaceShader = CustomMaterial.SurfaceShader(named: "waveSurface", in: mtlLibrary)
        var material = PhysicallyBasedMaterial()
        material.baseColor.tint = .clear
        material.roughness = 0.7
        material.metallic = 0.8
        material.anisotropyLevel.scale = 0.8
        
        entity = ModelEntity(mesh: try! .generateDetailedPlane(width: 1, depth: 1, vertices: (100, 100)),
                             materials: [material])
        
        entity.model?.materials = entity.model?.materials.map {
            try! CustomMaterial(from: $0, surfaceShader: surfaceShader, geometryModifier: geometryModifier)
        } ?? [Material]()
        
        entity.generateCollisionShapes(recursive: true)
        entity.setParent(anchor)
        
        arView.installGestures(.all, for: entity)
        arView.scene.anchors.append(anchor)
    }
}
