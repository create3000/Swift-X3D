//
//  CADAssembly.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class CADAssembly :
   X3DGroupingNode,
   X3DProductStructureChildNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "CADAssembly" }
   internal final override class var component      : String { "CADGeometry" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   
   // Fields
   
   @SFString public final var name : String = ""

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initProductStructureChildNode ()

      types .append (.CADAssembly)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOutput,    "name",           $name)
      addField (.initializeOnly, "bboxSize",       $bboxSize)
      addField (.initializeOnly, "bboxCenter",     $bboxCenter)
      addField (.inputOnly,      "addChildren",    $addChildren)
      addField (.inputOnly,      "removeChildren", $removeChildren)
      addField (.inputOutput,    "children",       $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> CADAssembly
   {
      return CADAssembly (with: executionContext)
   }
}
