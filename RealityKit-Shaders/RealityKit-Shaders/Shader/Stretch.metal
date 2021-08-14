//
//  Stretch.metal
//  RealityKit-Shaders
//
//  Created by Artyom Mihailovich on 6/15/21.
//

#include <metal_stdlib>
#include <RealityKit/RealityKit.h>
using namespace metal;

[[visible]]

void stretch(realitykit::geometry_parameters parameters){
    float3 position = parameters.geometry().model_position();
    float offsetMult = sin(parameters.uniforms().time() * 3);
    
    if (position.y > 0) {
        parameters.geometry().set_model_position_offset(float3(position.x * offsetMult, 0, position.z * offsetMult));
    }
}
