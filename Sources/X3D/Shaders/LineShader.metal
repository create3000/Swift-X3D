//
//  LineShader.metal
//  X3D
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#include "ShaderDefinitions.h"
#include "Library/Fog.h"
#include "Library/Material.h"

#include <metal_stdlib>

using namespace metal;

struct x3d_VertexOut
{
   float  fogDepth;
   float4 color;
   float4 worldPoint;
   float4 point [[position]];
};

vertex
x3d_VertexOut
lineVertexShader (const unsigned int vertexId         [[ vertex_id ]],
                  const device x3d_VertexIn* vertices [[ buffer (0) ]],
                  constant x3d_Uniforms & uniforms    [[ buffer (1) ]])
{
   x3d_VertexIn  in  = vertices [vertexId];
   x3d_VertexOut out = x3d_VertexOut ();
   
   out .fogDepth   = in .fogDepth;
   out .color      = getColor (in, uniforms);
   out .worldPoint = uniforms .modelViewMatrix * in .point;
   out .point      = uniforms .projectionMatrix * out .worldPoint;

   return out;
}

fragment
float4
lineFragmentShader (const x3d_VertexOut in           [[ stage_in ]],
                    constant x3d_Uniforms & uniforms [[ buffer (1) ]])
{
   float4 finalColor;

   finalColor .rgb = getFogColor (in .color .rgb, uniforms .fog, in .fogDepth, in .worldPoint .xyz);
   finalColor .a   = in .color .a;

   return finalColor;
}
