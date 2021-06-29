//
//  ShaderDefinitions.h
//  X3D
//
//  Created by Holger Seelig on 18.08.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

#include <simd/simd.h>

#define x3d_NoFog          0
#define x3d_LinearFog      1
#define x3d_ExponentialFog 2

#define x3d_MaxLights        8
#define x3d_DirectionalLight 1
#define x3d_PointLight       2
#define x3d_SpotLight        3

#define x3d_MaxTextures 2

#define x3d_SPHERE                      0
#define x3d_CAMERASPACENORMAL           1
#define x3d_CAMERASPACEPOSITION         2
#define x3d_CAMERASPACEREFLECTIONVECTOR 3
#define x3d_SPHERE_LOCAL                4
#define x3d_COORD                       5
#define x3d_COORD_EYE                   6
#define x3d_NOISE                       7
#define x3d_NOISE_EYE                   8
#define x3d_SPHERE_REFLECT              9
#define x3d_SPHERE_REFLECT_LOCAL        10

struct x3d_VertexIn
{
   float         fogDepth;
   vector_float4 color;
   vector_float4 texCoords [x3d_MaxTextures];
   vector_float3 normal;
   vector_float4 point;
};

struct x3d_FogParameters
{
   int             type;
   vector_float3   color;
   float           visibilityRange;
   bool            fogCoord;
   matrix_float3x3 matrix;
};

struct x3d_LightSourceParameters
{
   int             type;
   vector_float3   color;
   float           intensity;
   float           ambientIntensity;
   vector_float3   attenuation;
   vector_float3   location;
   vector_float3   direction;
   float           radius;
   float           beamWidth;
   float           cutOffAngle;
   matrix_float3x3 matrix;
   #ifdef X3D_SHADOWS
   vector_float3   shadowColor;
   float           shadowIntensity;
   float           shadowBias;
   matrix_float4x4 shadowMatrix;
   int             shadowMapSize;
   #endif
};

struct x3d_MaterialParameters
{
   float         ambientIntensity;
   vector_float3 diffuseColor;
   vector_float3 specularColor;
   vector_float3 emissiveColor;
   float         shininess;
   float         transparency;
};

struct x3d_TextureCoordinateGeneratorParameters
{
   int   mode;
   float parameter [6];
};

struct x3d_Uniforms
{
   vector_int4     viewport;
   matrix_float4x4 projectionMatrix;
   matrix_float4x4 modelViewMatrix;
   matrix_float3x3 normalMatrix;
   matrix_float4x4 textureMatrices [x3d_MaxTextures];
   
   struct x3d_FogParameters fog;

   bool colorMaterial;
   bool lighting;
   bool separateBackColor;

   struct x3d_MaterialParameters frontMaterial;
   struct x3d_MaterialParameters backMaterial;
   
   int numLights;
   int numTextures;
   
   struct x3d_TextureCoordinateGeneratorParameters textureCoordinateGenerator [x3d_MaxTextures];
};

#endif /* ShaderDefinitions_h */
