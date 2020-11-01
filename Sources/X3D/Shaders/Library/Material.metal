//
//  Color.metal
//  X3D
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#include "Material.h"

float4
getColor (const x3d_VertexIn in,
          constant x3d_Uniforms & uniforms)
{
   if (uniforms .lighting)
   {
      float alpha = 1 - uniforms .frontMaterial .transparency;

      if (uniforms .colorMaterial)
      {
         return float4 (in .color .rgb, in .color .a * alpha);
      }
      else
      {
         return float4 (uniforms .frontMaterial .emissiveColor, alpha);
      }
   }
   else
   {
      if (uniforms .colorMaterial)
         return in .color;
      else
         return float4 (1.0);
   }
}

float
getSpotFactor (const float cutOffAngle,
               const float beamWidth,
               const float3 L,
               const float3 d)
{
   float spotAngle = acos (clamp (dot (-L, d), -1.0, 1.0));

   if (spotAngle >= cutOffAngle)
      return 0.0;
   else if (spotAngle <= beamWidth)
      return 1.0;

   return (spotAngle - cutOffAngle) / (beamWidth - cutOffAngle);
}
