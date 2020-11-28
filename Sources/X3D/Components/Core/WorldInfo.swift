//
//  WorldInfo.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class WorldInfo :
   X3DInfoNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "WorldInfo" }
   internal final override class var component      : String { "Core" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFString public final var title : String = ""
   @MFString public final var info  : [String]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.WorldInfo)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.initializeOnly, "title",    $title)
      addField (.initializeOnly, "info",     $info)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> WorldInfo
   {
      return WorldInfo (with: executionContext)
   }
}
