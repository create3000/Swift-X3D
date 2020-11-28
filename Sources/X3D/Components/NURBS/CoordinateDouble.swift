//
//  CoordinateDouble.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CoordinateDouble :
   X3DCoordinateNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "CoordinateDouble" }
   internal final override class var component      : String { "NURBS" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "coord" }

   // Fields

   @MFVec3d public final var point : [Vector3d]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.CoordinateDouble)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "point",    $point)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CoordinateDouble
   {
      return CoordinateDouble (with: executionContext)
   }
   
   // Member access
   
   internal final override var isEmpty : Bool { point .isEmpty }
   internal final override var count : Int { point .count }

   internal final override func get1Point (at index : Int) -> Vector3f
   {
      if point .indices .contains (index)
      {
         return Vector3f (point [index])
      }

      return .zero
   }
   
   internal final override func makeNormal (index1 : Int, index2 : Int, index3 : Int) -> Vector3f
   {
      let indices = point .indices
      
      if indices .contains (index1) && indices .contains (index2) && indices .contains (index3)
      {
         return Vector3f (normal (point [index1], point [index2], point [index3]))
      }
      
      return .zero
   }
   
   internal final override func makeNormal (index1 : Int, index2 : Int, index3 : Int, index4 : Int) -> Vector3f
   {
      let indices = point .indices
      
      if indices .contains (index1) && indices .contains (index2) && indices .contains (index3) && indices .contains (index4)
      {
         return Vector3f (normal (point [index1], point [index2], point [index3], point [index4]))
      }
      
      return .zero
   }
}
