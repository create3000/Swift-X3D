//
//  TextureCoordinateGenerator.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextureCoordinateGenerator :
   X3DTextureCoordinateNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TextureCoordinateGenerator" }
   internal final override class var component      : String { "Texturing" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "texCoord" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFString public final var mode      : String = "SPHERE"
   @MFFloat  public final var parameter : [Float]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureCoordinateGenerator)

      addField (.inputOutput, "metadata",  $metadata)
      addField (.inputOutput, "mode",      $mode)
      addField (.inputOutput, "parameter", $parameter)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureCoordinateGenerator
   {
      return TextureCoordinateGenerator (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $mode      .addInterest ("set_mode",      { $0 .set_mode () },      self)
      $parameter .addInterest ("set_parameter", { $0 .set_parameter () }, self)
      
      set_mode ()
      set_parameter ()
   }
   
   static let modeTypes : [String : Int32] = [
      "SPHERE" :                      x3d_Sphere,
      "CAMERASPACENORMAL" :           x3d_CameraSpaceNormal,
      "CAMERASPACEPOSITION" :         x3d_CameraSpacePosition,
      "CAMERASPACEREFLECTIONVECTOR" : x3d_CameraSpaceReflectionVector,
      "SPHERE-LOCAL" :                x3d_SphereLocal,
      "COORD" :                       x3d_Coord,
      "COORD-EYE" :                   x3d_CoordEye,
      "NOISE" :                       x3d_Noise,
      "NOISE-EYE" :                   x3d_NoiseEye,
      "SPHERE-REFLECT" :              x3d_SphereReflect,
      "SPHERE-REFLECT-LOCAL" :        x3d_SphereReflectLocal,
   ]
   
   private final var modeValue : Int32 = x3d_None
   
   private final func set_mode ()
   {
      modeValue = TextureCoordinateGenerator .modeTypes [mode] ?? x3d_Sphere
   }
   
   private final var parameterValue : (Float32, Float32, Float32, Float32, Float32, Float32) = (0, 0, 0, 0, 0, 0)
   
   private final func set_parameter ()
   {
      // 0
      
      if parameter .count > 0
      {
         parameterValue .0 = parameter [0]
      }
      else
      {
         parameterValue .0 = 0
      }
      
      // 1
      
      if parameter .count > 1
      {
         parameterValue .1 = parameter [1]
      }
      else
      {
         parameterValue .1 = 0
      }
      
      // 2
      
      if parameter .count > 2
      {
         parameterValue .2 = parameter [2]
      }
      else
      {
         parameterValue .2 = 0
      }
      
      // 3
      
      if parameter .count > 3
      {
         parameterValue .3 = parameter [3]
      }
      else
      {
         parameterValue .3 = 0
      }
      
      // 4
      
      if parameter .count > 4
      {
         parameterValue .4 = parameter [4]
      }
      else
      {
         parameterValue .4 = 0
      }
      
      // 5
      
      if parameter .count > 5
      {
         parameterValue .5 = parameter [5]
      }
      else
      {
         parameterValue .5 = 0
      }
   }
   
   internal final override func setUniforms (_ uniforms : UnsafeMutablePointer <x3d_Uniforms>, to channel : Int32)
   {
      switch channel
      {
         case 0: do
         {
            uniforms .pointee .textureCoordinateGenerator .0 .mode      = modeValue
            uniforms .pointee .textureCoordinateGenerator .0 .parameter = parameterValue
         }
         case 1: do
         {
            uniforms .pointee .textureCoordinateGenerator .1 .mode      = modeValue
            uniforms .pointee .textureCoordinateGenerator .1 .parameter = parameterValue
         }
         default:
            break
      }
   }
}
