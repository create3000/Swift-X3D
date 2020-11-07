//
//  Fog.h
//  Sunrise X3D Editor
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#ifndef Fog_h
#define Fog_h

#include "../ShaderDefinitions.h"

#include <metal_stdlib>

using namespace metal;

float3
getFogColor (const float3 color, const x3d_FogParameters fog, float fogDepth, float3 point);

#endif /* Fog_h */
