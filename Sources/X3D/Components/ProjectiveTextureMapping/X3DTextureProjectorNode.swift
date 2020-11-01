//
//  X3DTextureProjectorNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DTextureProjectorNode :
   X3DChildNode
{
   // Fields

   @SFString public final var description  : String = ""
   @SFBool   public final var on           : Bool = true
   @SFBool   public final var global       : Bool = true
   @SFVec3f  public final var location     : Vector3f = Vector3f (0, 0, 0)
   @SFVec3f  public final var direction    : Vector3f = Vector3f (0, 0, 1)
   @SFVec3f  public final var upVector     : Vector3f = Vector3f (0, 0, 1)
   @SFFloat  public final var nearDistance : Float = 1
   @SFFloat  public final var farDistance  : Float = 10
   @SFFloat  public final var aspectRatio  : Float = 0
   @SFNode   public final var texture      : X3DNode?

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DTextureProjectorNode)

      $location     .unit = .length
      $nearDistance .unit = .length
      $farDistance  .unit = .length
   }
}
