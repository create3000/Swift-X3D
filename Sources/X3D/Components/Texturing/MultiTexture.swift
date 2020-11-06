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
   
   public final override class var typeName       : String { "MultiTexture" }
   public final override class var component      : String { "Texturing" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "texture" }

   // Fields

   @SFColor  public final var color    : Color3f = .one
   @SFFloat  public final var alpha    : Float = 1
   @MFString public final var mode     : MFString .Value
   @MFString public final var source   : MFString .Value
   @MFString public final var function : MFString .Value
   @MFNode   public final var texture  : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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
