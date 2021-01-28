//
//  MultiTexture.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class MultiTexture :
   X3DTextureNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "MultiTexture" }
   internal final override class var component      : String { "Texturing" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "texture" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFColor  public final var color    : Color3f = .one
   @SFFloat  public final var alpha    : Float = 1
   @MFString public final var mode     : [String]
   @MFString public final var source   : [String]
   @MFString public final var function : [String]
   @MFNode   public final var texture  : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.MultiTexture)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "color",    $color)
      addField (.inputOutput, "alpha",    $alpha)
      addField (.inputOutput, "mode",     $mode)
      addField (.inputOutput, "source",   $source)
      addField (.inputOutput, "function", $function)
      addField (.inputOutput, "texture",  $texture)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> MultiTexture
   {
      return MultiTexture (with: executionContext)
   }
}
