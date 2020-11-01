//
//  Texture.metal
//  X3D
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#include "Texture.h"

float4
getTextureColor (const int numTextures,
                 const texture2d <float> texture0,
                 const texture2d <float> texture1,
                 const sampler sampler0,
                 const sampler sampler1,
                 const float4 texCoord0,
                 const float4 texCoord1,
                 const float4 diffuseColor,
                 const float4 specularColor)
{
   auto t = texture0 .sample (sampler0, texCoord0 .xy / texCoord0 .w);

   return t * diffuseColor;
}

float4
getProjectiveTextureColor (const float4 currentColor)
{
   return currentColor;
}
