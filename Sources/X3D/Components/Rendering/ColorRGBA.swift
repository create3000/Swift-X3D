//
//  ColorRGBA.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ColorRGBA :
   X3DColorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "ColorRGBA" }
   internal final override class var component      : String { "Rendering" }
   internal final override class var componentLevel : Int32 { 4 }
   internal final override class var containerField : String { "color" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFColorRGBA public final var color : [Color4f]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ColorRGBA)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "color",    $color)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ColorRGBA
   {
      return ColorRGBA (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $color .addInterest ("set_color", { $0 .set_color () }, self)
      
      set_color ()
   }
   
   // Event handlers
   
   private final func set_color ()
   {
      setTransparent (color .contains { $0 .a < 1 })
   }
   
   // Member access
   
   internal final override func get1Color (at index : Int) -> Color4f
   {
      if color .indices .contains (index)
      {
         return color [index]
      }
      
      if index >= 0 && !color .isEmpty
      {
         return color [index % color .count]
      }
      
      return Color4f .one
   }
}
