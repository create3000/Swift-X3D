//
//  FogCoordinate.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class FogCoordinate :
   X3DGeometricPropertyNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "FogCoordinate" }
   internal final override class var component      : String { "EnvironmentalEffects" }
   internal final override class var componentLevel : Int32 { 4 }
   internal final override class var containerField : String { "fogCoord" }

   // Fields

   @MFFloat public final var depth : [Float]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.FogCoordinate)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "depth",    $depth)

      $depth .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> FogCoordinate
   {
      return FogCoordinate (with: executionContext)
   }
   
   // Member access
   
   internal final var isEmpty : Bool { depth .isEmpty }
   internal final var count : Int { depth .count }

   internal final func get1Depth (at index : Int) -> Float
   {
      if depth .indices .contains (index)
      {
         return depth [index]
      }
      
      if index >= 0 && !depth .isEmpty
      {
         return depth [index % depth .count]
      }

      return 0
   }
}
