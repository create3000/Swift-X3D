//
//  Normal.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class Normal :
   X3DNormalNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Normal" }
   internal final override class var component      : String { "Rendering" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "normal" }

   // Fields

   @MFVec3f public final var vector : [Vector3f]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Normal)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "vector",   $vector)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Normal
   {
      return Normal (with: executionContext)
   }
   
   // Member access
   
   internal final override var isEmpty : Bool { vector .isEmpty }
   internal final override var count : Int { vector .count }
   
   internal final override func get1Vector (at index : Int) -> Vector3f
   {
      if vector .indices .contains (index)
      {
         return vector [index]
      }
      
      if index >= 0 && !vector .isEmpty
      {
         return vector [index % vector .count]
      }

      return .zero
   }
}
