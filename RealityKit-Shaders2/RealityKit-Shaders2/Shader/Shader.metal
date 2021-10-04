//
//  Shader.metal
//  RealityKit-Shaders2
//
//  Created by Artyom Mihailovich on 10/4/21.
//

#include <metal_stdlib>
#include "RealityKit/RealityKit.h"
using namespace metal;

[[visible]]
void surfaceShader(realitykit::surface_parameters parameters) {
    auto surface = parameters.surface();
    
    float3 col = 0.5 + 0.5 * cos(parameters.uniforms().time() + parameters.geometry().model_position().xyx + float3(0,2,4));
    
    surface.set_base_color(half3(col));
    surface.set_roughness(0.5);
    surface.set_ambient_occlusion(2.0);
}
