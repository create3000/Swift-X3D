//
//  Texture.metal
//  X3D
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#include "Perlin.h"

//https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83

#define M_PI 3.14159265358979323846

float rand (float2 co) { return fract (sin (dot (co.xy, float2 (12.9898,78.233))) * 43758.5453); }
float rand (float2 co, float l) { return rand (float2 (rand (co), l)); }
float rand (float2 co, float l, float t) { return rand (float2 (rand (co, l), t)); }

float
perlin (const float2 p, const float dim, const float time)
{
   const float2 pos   = floor (p * dim);
   const float2 posx  = pos + float2 (1.0, 0.0);
   const float2 posy  = pos + float2 (0.0, 1.0);
   const float2 posxy = pos + float2 (1.0);

   const float c   = rand (pos,   dim, time);
   const float cx  = rand (posx,  dim, time);
   const float cy  = rand (posy,  dim, time);
   const float cxy = rand (posxy, dim, time);

   const float2 d = -0.5 * cos (fract (p * dim) * M_PI) + 0.5;

   const float ccx    = mix (c,   cx,    d.x);
   const float cycxy  = mix (cy,  cxy,   d.x);
   const float center = mix (ccx, cycxy, d.y);

   return center * 2.0 - 1.0;
}

float3
perlin (const float3 p)
{
   return float3 (perlin (p.xy, 1.0, 0.0),
                  perlin (p.yz, 1.0, 0.0),
                  perlin (p.zx, 1.0, 0.0));
}
