//
//  Material.h
//  Titania X3D Editor
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#ifndef Material_h
#define Material_h

#include "../ShaderDefinitions.h"

#include <metal_stdlib>

using namespace metal;

vector_float4
getColor (const x3d_VertexIn in,
          constant x3d_Uniforms & uniforms);

float
getSpotFactor (const float cutOffAngle,
               const float beamWidth,
               const float3 L,
               const float3 d);

#endif /* Material_h */
