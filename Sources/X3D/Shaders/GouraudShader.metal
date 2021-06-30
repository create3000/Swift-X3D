//
//  GouraudShader.metal
//  X3D
//
//  Created by Holger Seelig on 25.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#include "ShaderDefinitions.h"
#include "Library/Fog.h"
#include "Library/Material.h"
#include "Library/Texture.h"

#include <metal_stdlib>

using namespace metal;

float4
getGouraudMaterialColor (const bool front_facing,
                         const x3d_VertexIn in,
                         const x3d_VertexOut out,
                         constant x3d_Uniforms & uniforms,
                         constant x3d_LightSourceParameters* lightSources)
{
   const auto color         = in .color;
   const auto normal        = out .normal;
   const auto point         = out .cameraPoint .xyz;
   const auto numLights     = uniforms .numLights;
   const auto lighting      = uniforms .lighting;
   const auto material      = front_facing ? uniforms .frontMaterial : uniforms .backMaterial;
   const auto colorMaterial = uniforms .colorMaterial;

   if (lighting)
   {
      const float3 N = normalize (front_facing ? normal : -normal);
      const float3 V = normalize (-point); // normalized vector from point on geometry to viewer's position
      
      // Calculate diffuseFactor & alpha

      float3 diffuseFactor = float3 (1);
      float  alpha         = 1 - material .transparency;

      if (colorMaterial)
      {
         diffuseFactor = color .rgb;
         alpha        *= color .a;
      }
      else
      {
         diffuseFactor = material .diffuseColor;
      }

      const float3 ambientTerm = diffuseFactor * material .ambientIntensity;

      // Apply light sources

      float3 finalColor = float3 (0);

      for (int i = 0; i < x3d_MaxLights; i ++)
      {
         if (i == numLights)
            break;

         x3d_LightSourceParameters light = lightSources [i];

         const float3 vL = light .location - point; // Light to fragment
         const float  dL = length (light .matrix * vL);
         const bool   di = light .type == x3d_DirectionalLight;

         if (di || dL <= light .radius)
         {
            const float3 d = light .direction;
            const float3 c = light .attenuation;
            const float3 L = di ? -d : normalize (vL);      // Normalized vector from point on geometry to light source i position.
            const float3 H = normalize (L + V);             // Specular term

            const float  lightAngle     = max (dot (N, L), 0.0);      // Angle between normal and light ray.
            const float3 diffuseTerm    = diffuseFactor * lightAngle;
            const float  specularFactor = material .shininess > 0 ? pow (max (dot (N, H), 0.0), material .shininess * 128) : 1;
            const float3 specularTerm   = material .specularColor * specularFactor;

            const float  attenuationFactor     = di ? 1.0 : 1.0 / max (c [0] + c [1] * dL + c [2] * (dL * dL), 1.0);
            const float  spotFactor            = light .type == x3d_SpotLight ? getSpotFactor (light .cutOffAngle, light .beamWidth, L, d) : 1;
            const float  attenuationSpotFactor = attenuationFactor * spotFactor;
            const float3 ambientColor          = light .ambientIntensity * ambientTerm;
            const float3 diffuseSpecularColor  = light .intensity * (diffuseTerm + specularTerm);

            #ifdef X3D_SHADOWS
               if (lightAngle > 0)
                  diffuseSpecularColor = mix (diffuseSpecularColor, light .shadowColor, getShadowIntensity (i, light));
            #endif

            finalColor += attenuationSpotFactor * light .color * (ambientColor + diffuseSpecularColor);
         }
      }

      finalColor += material .emissiveColor;

      return float4 (clamp (finalColor, 0, 1), alpha);
   }
   else
   {
      float4 finalColor = float4 (1);

      if (colorMaterial)
      {
         finalColor = color;
      }

      return finalColor;
   }
}

vertex
x3d_VertexOut
gouraudVertexShader (const unsigned int vertexId                      [[ vertex_id ]],
                     const device x3d_VertexIn* vertices              [[ buffer (0) ]],
                     constant x3d_Uniforms & uniforms                 [[ buffer (1) ]],
                     constant x3d_LightSourceParameters* lightSources [[ buffer (2) ]])
{
   x3d_VertexIn  in  = vertices [vertexId];
   x3d_VertexOut out = x3d_VertexOut ();

   out .fogDepth    = in .fogDepth;
   out .texCoord0   = uniforms .textureMatrices [0] * in .texCoords [0];
   out .texCoord1   = uniforms .textureMatrices [1] * in .texCoords [1];
   out .localNormal = in .normal;
   out .normal      = uniforms .normalMatrix * in .normal;
   out .localPoint  = in .point .xyz;
   out .cameraPoint = uniforms .modelViewMatrix * in .point;
   out .point       = uniforms .projectionMatrix * out .cameraPoint;
   out .frontColor  = getGouraudMaterialColor (true,  in, out, uniforms, lightSources);
   out .backColor   = getGouraudMaterialColor (false, in, out, uniforms, lightSources);

   return out;
}

fragment
float4
gouraudFragmentShader (const bool front_facing          [[ front_facing ]],
                       const x3d_VertexOut in           [[ stage_in ]],
                       constant x3d_Uniforms & uniforms [[ buffer (1) ]],
                       const texture2d <float> texture0 [[ texture (0) ]],
                       const texture2d <float> texture1 [[ texture (1) ]],
                       const sampler sampler0           [[ sampler (0) ]],
                       const sampler sampler1           [[ sampler (1) ]])
{
   float4 finalColor = front_facing ? in .frontColor : in .backColor;
   
   if (uniforms .numTextures > 0)
   {
      finalColor = getTextureColor (front_facing,
                                    in,
                                    uniforms,
                                    texture0,
                                    texture1,
                                    sampler0,
                                    sampler1,
                                    in .texCoord0,
                                    in .texCoord1,
                                    finalColor,
                                    float4 (1));
   }

   finalColor      = getProjectiveTextureColor (finalColor);
   finalColor .rgb = getFogColor (finalColor .rgb, uniforms .fog, in .fogDepth, in .cameraPoint .xyz);
   
   return finalColor;
}
