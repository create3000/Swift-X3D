//
//  TextureCoordinate.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextureCoordinate :
   X3DTextureCoordinateNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "TextureCoordinate" }
   public final override class var component      : String { "Texturing" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "texCoord" }

   // Fields

   @MFVec2f public final var point : MFVec2f .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.TextureCoordinate)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "point",    $point)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextureCoordinate
   {
      return TextureCoordinate (with: executionContext)
   }

   // Member access
   
   internal final override func get1Point (at index: Int) -> Vector4f
   {
      if point .indices .contains (index)
      {
         let p = point [index]
         
         return Vector4f (p .x ,p .y, 0, 1)
      }
      
      if index >= 0 && !point .isEmpty
      {
         let p = point [index % point .count]
         
         return Vector4f (p .x ,p .y, 0, 1)
      }
      
      return Vector4f .zero
   }
}
