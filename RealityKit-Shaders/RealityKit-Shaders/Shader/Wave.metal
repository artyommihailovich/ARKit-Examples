//
//  Wave.metal
//  RealityKit-Shaders
//
//  Created by Artyom Mihailovich on 6/15/21.
//

#include <metal_stdlib>
#include "RealityKit/RealityKit.h"
using namespace metal;


[[visible]]
void waveMotion(realitykit::geometry_parameters parameters) {
    float xSpeed = 1;
    float zSpeed = 1.1;
    float xAmplitude = 0.01;
    float zAmplitude = 0.02;
    
    float3 position = parameters.geometry().model_position();
    
    float xPeriod = (sin(position.x * 40 + parameters.uniforms().time() / 40) + 3) * 2;
    float zPeriod = (sin(position.z * 20 + parameters.uniforms().time() / 13) + 3);
    
    float xOffset = xAmplitude * sin(xSpeed * parameters.uniforms().time() + zPeriod * position.x);
    float zOffset = zAmplitude * sin(zSpeed * parameters.uniforms().time() + xPeriod * position.z);
    
    parameters.geometry().set_model_position_offset(float3(0, xOffset + zOffset, 0));
}

[[visible]]
void waveSurface(realitykit::surface_parameters parameters) {
    auto surface = parameters.surface();
    
    float maxAmplitude = 0.03;
    half3 oceanBlue = half3(0, 0.412, 0.58);
    
    float waveHeight = (parameters.geometry().model_position().y + maxAmplitude) / (maxAmplitude * 2);
    
    surface.set_base_color(oceanBlue + min(1.0f, pow(waveHeight, 8)) * (1 - oceanBlue));
}
