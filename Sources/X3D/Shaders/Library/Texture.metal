//
//  Texture.metal
//  X3D
//
//  Created by Holger Seelig on 11.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#include "Texture.h"
#include "Perlin.h"

float4
getTextureCoordinate (const bool front_facing,
                      const x3d_VertexOut in,
                      const x3d_TextureCoordinateGeneratorParameters textureCoordinateGenerator,
                      const float4 texCoord)
{
   const int mode = textureCoordinateGenerator .mode;

   switch (mode)
   {
      case x3d_None:
      {
         return texCoord;
      }
      case x3d_Sphere:
      {
         const float2 N = normalize (front_facing ? in .normal : -in .normal) .xy;

         return float4 (N / 2.0 + 0.5, 0.0, 1.0);
      }
      case x3d_CameraSpaceNormal:
      {
         const float3 N = normalize (front_facing ? in .normal : -in .normal);

         return float4 (N, 1.0);
      }
      case x3d_CameraSpacePosition:
      {
         return float4 (in .worldPoint .xyz, 1.0);
      }
      case x3d_CameraSpaceReflectionVector:
      {
         const float3 N = normalize (front_facing ? -in .normal : in .normal);

         return float4 (reflect (normalize (in .worldPoint .xyz), N), 1.0);
      }
      case x3d_SphereLocal:
      {
         const float2 N = normalize (front_facing ? in .localNormal : -in .localNormal) .xy;

         return float4 (N / 2.0 + 0.5, 0.0, 1.0);
      }
      case x3d_Coord:
      {
         return float4 (in .localPoint, 1.0);
      }
      case x3d_CoordEye:
      {
         return float4 (in .worldPoint .xyz, 1.0);
      }
      case x3d_Noise:
      {
         const auto scale       = float3 (textureCoordinateGenerator .parameter [0], textureCoordinateGenerator .parameter [1], textureCoordinateGenerator .parameter [2]);
         const auto translation = float3 (textureCoordinateGenerator .parameter [3], textureCoordinateGenerator .parameter [4], textureCoordinateGenerator .parameter [5]);

         return float4 (perlin (in .localPoint * scale + translation), 1.0);
      }
      case x3d_NoiseEye:
      {
         const auto scale       = float3 (textureCoordinateGenerator .parameter [0], textureCoordinateGenerator .parameter [1], textureCoordinateGenerator .parameter [2]);
         const auto translation = float3 (textureCoordinateGenerator .parameter [3], textureCoordinateGenerator .parameter [4], textureCoordinateGenerator .parameter [5]);

         return float4 (perlin (in .worldPoint .xyz * scale + translation), 1.0);
      }
      case x3d_SphereReflect:
      {
         const auto N   = normalize (front_facing ? -in .normal : in .normal);
         const auto eta = textureCoordinateGenerator .parameter [0];

         return float4 (refract (normalize (in .worldPoint .xyz), N, eta), 1.0);
      }
      case x3d_SphereReflectLocal:
      {
         const auto N   = normalize (front_facing ? -in .localNormal : in .localNormal);
         const auto eta = textureCoordinateGenerator .parameter [0];
         const auto eye = float3 (textureCoordinateGenerator .parameter [1], textureCoordinateGenerator .parameter [2], textureCoordinateGenerator .parameter [3]);

         return float4 (refract (normalize (in .localPoint - eye), N, eta), 1.0);
      }
      default:
      {
         return texCoord;
      }
   }
}

float4
getTextureColor (const bool front_facing,
                 const x3d_VertexOut in,
                 constant x3d_Uniforms & uniforms,
                 const texture2d <float> texture0,
                 const texture2d <float> texture1,
                 const sampler sampler0,
                 const sampler sampler1,
                 const float4 texCoord0,
                 const float4 texCoord1,
                 const float4 diffuseColor,
                 const float4 specularColor)
{
   const auto texCoord = getTextureCoordinate (front_facing, in, uniforms .textureCoordinateGenerator [0], texCoord0);
   const auto t        = texture0 .sample (sampler0, texCoord .xy / texCoord .w);

   return t * diffuseColor;
}

float4
getProjectiveTextureColor (const float4 currentColor)
{
   return currentColor;
}
