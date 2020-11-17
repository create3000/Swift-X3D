//
//  X3DLightNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DLightNode :
   X3DChildNode
{
   // Fields

   @SFBool  public final var global           : Bool = true
   @SFBool  public final var on               : Bool = true
   @SFColor public final var color            : Color3f = .one
   @SFFloat public final var intensity        : Float = 1
   @SFFloat public final var ambientIntensity : Float = 0
   @SFColor public final var shadowColor      : Color3f = .zero
   @SFFloat public final var shadowIntensity  : Float = 0
   @SFFloat public final var shadowBias       : Float = 0.005
   @SFInt32 public final var shadowMapSize    : Int32 = 1024

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DLightNode)
   }
   
   // Traverse
   
   internal final func push (_ renderer : Renderer, _ group : X3DGroupingNode)
   {
      guard on else { return }

      if global
      {
         let lightContainer = LightContainer (lightNode: self,
                                              modelViewMatrix: renderer .modelViewMatrix .top)
         
         renderer .globalLights .append (lightContainer)
      }
      else
      {
         let lightContainer = LightContainer (lightNode: self,
                                              modelViewMatrix: renderer .modelViewMatrix .top)
         
         renderer .localLights .append (lightContainer)
      }
   }
   
   internal final func pop (_ renderer : Renderer)
   {
      guard on && !global else { return }
      
      renderer .localLights .removeLast ()
   }
   
   // Rendering
   
   internal func setUniforms (_ uniforms : UnsafeMutablePointer <x3d_LightSourceParameters>, _ modelViewMatrix : Matrix4f, _ matrix : Matrix3f) { }
}
