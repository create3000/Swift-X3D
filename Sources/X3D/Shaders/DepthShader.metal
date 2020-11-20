//
//  DepthShader.metal
//  X3D
//
//  Created by Holger Seelig on 25.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#include "ShaderDefinitions.h"

#include <metal_stdlib>

using namespace metal;

struct x3d_VertexOut
{
   float4 point [[position]];
};

vertex
x3d_VertexOut
depthVertexShader (const unsigned int vertexId         [[ vertex_id ]],
                   const device x3d_VertexIn* vertices [[ buffer (0) ]],
                   constant x3d_Uniforms & uniforms    [[ buffer (1) ]])
{
   x3d_VertexIn  in  = vertices [vertexId];
   x3d_VertexOut out = x3d_VertexOut ();

   out .point = uniforms .projectionMatrix * (uniforms .modelViewMatrix * in .point);

   return out;
}

fragment
float4
depthFragmentShader ()
{
   return float4 (1);
}
