//
//  MetadataString.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class MetadataString :
   X3DNode,
   X3DMetadataObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "MetadataString" }
   internal final override class var component      : String { "Core" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "metadata" }

   // Fields

   @SFString public final var name      : String = ""
   @SFString public final var reference : String = ""
   @MFString public final var value     : [String]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initMetadataObject ()

      types .append (.MetadataString)

      addField (.inputOutput, "metadata",  $metadata)
      addField (.inputOutput, "name",      $name)
      addField (.inputOutput, "reference", $reference)
      addField (.inputOutput, "value",     $value)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> MetadataString
   {
      return MetadataString (with: executionContext)
   }
}
