//
//  ARView.swift
//  RealityKit-Shaders
//
//  Created by Artyom Mihailovich on 6/15/21.
//

import ARKit
import RealityKit

extension ARView {
    func configureARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        self.session.run(configuration)
    }
    
//    func addPeopleOcclusion() {
//            guard let configuration = self.session.configuration as? ARWorldTrackingConfiguration else {
//                fatalError("Unexpectedly failed to get the configuration.")
//            }
//            guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
//                fatalError("People occlusion is not supported on this device.")
//            }
//            configuration.frameSemantics.insert(.personSegmentationWithDepth)
//            self.session.run(configuration)
//        }
}
