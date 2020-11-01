//
//  Fog.metal
//  X3D
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#include "Fog.h"

float
getFogInterpolant (const x3d_FogParameters fog, float fogDepth, float3 worldPoint)
{
   // Returns 0.0 for fog color and 1.0 for material color.

   if (fog .type == x3d_NoFog)
      return 1;

   if (fog .fogCoord)
      return clamp (1 - fogDepth, 0.0, 1.0);

   float visibilityRange = fog .visibilityRange;

   if (visibilityRange <= 0)
      return 1;

   float dV = length (fog .matrix * worldPoint);

   if (dV >= visibilityRange)
      return 0;

   switch (fog .type)
   {
      case x3d_LinearFog:
      {
         return (visibilityRange - dV) / visibilityRange;
      }
      case x3d_ExponentialFog:
      {
         return exp (-dV / (visibilityRange - dV));
      }
      default:
      {
         return 1;
      }
   }
}

float3
getFogColor (const float3 color, const x3d_FogParameters fog, float fogDepth, float3 worldPoint)
{
   return mix (fog .color, color, getFogInterpolant (fog, fogDepth, worldPoint));
}
