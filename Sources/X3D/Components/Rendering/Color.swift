//
//  Color.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Color :
   X3DColorNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Color" }
   internal final override class var component      : String { "Rendering" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "color" }

   // Fields

   @MFColor public final var color : [Color3f]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Color)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "color",    $color)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Color
   {
      return Color (with: executionContext)
   }
   
   // Member access
   
   internal final override func get1Color (at index : Int) -> Color4f
   {
      if color .indices .contains (index)
      {
         return Color4f (color [index], 1)
      }
      
      if index >= 0 && !color .isEmpty
      {
         return Color4f (color [index % color .count], 1)
      }
      
      return Color4f .one
   }
}
