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
   
   public final override class var typeName       : String { "ColorRGBA" }
   public final override class var component      : String { "Rendering" }
   public final override class var componentLevel : Int32 { 4 }
   public final override class var containerField : String { "color" }

   // Fields

   @MFColorRGBA public final var color : MFColorRGBA .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
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
      
      $color .addInterest (ColorRGBA .set_color, self)
      
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
