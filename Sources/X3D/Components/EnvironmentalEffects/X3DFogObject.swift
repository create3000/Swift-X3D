//
//  X3DFogObject.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public protocol X3DFogObject :
   X3DNode
{
   // Fields

   //@SFColor  public final var color           : Color3f = .one
   //@SFString public final var fogType         : String = "LINEAR"
   //@SFFloat  public final var visibilityRange : Float = 0

   var color           : Color3f { get set }
   var fogType         : String { get set }
   var visibilityRange : Float { get set }
   
   // Properties
   
   var isHidden : Bool { get }
}

extension X3DFogObject
{
   // Construction
   
   internal func initFogObject (visibilityRange : SFFloat)
   {
      types .append (.X3DFogObject)
      
      visibilityRange .unit = .length
   }
   
   private var shaderFogType : Int32
   {
      switch fogType
      {
         case "LINEAR":
            return x3d_LinearFog
         case "EXPONENTIAL":
            return x3d_ExponentialFog
         default:
            return isHidden ? x3d_NoFog : x3d_LinearFog
      }
   }
   
   internal func setUniforms (_ uniforms : UnsafeMutablePointer <x3d_Uniforms>, _ matrix : Matrix3f)
   {
      uniforms .pointee .fog .type            = shaderFogType
      uniforms .pointee .fog .color           = color
      uniforms .pointee .fog .visibilityRange = max (0, visibilityRange)
      uniforms .pointee .fog .matrix          = matrix
   }
}
