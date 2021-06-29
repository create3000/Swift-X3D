//
//  Texture.h
//  Sunrise X3D Editor
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#ifndef Texture_h
#define Texture_h

#include "../ShaderDefinitions.h"

#include <metal_stdlib>

using namespace metal;

float4
getTextureColor (constant x3d_Uniforms & uniforms,
                 const texture2d <float> texture0,
                 const texture2d <float> texture1,
                 const sampler sampler0,
                 const sampler sampler1,
                 const float4 texCoord0,
                 const float4 texCoord1,
                 const float4 diffuseColor,
                 const float4 specularColor);

float4
getProjectiveTextureColor (const float4 currentColor);

#endif /* Texture_h */
