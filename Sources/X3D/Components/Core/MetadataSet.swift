//
//  MetadataSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class MetadataSet :
   X3DNode,
   X3DMetadataObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "MetadataSet" }
   internal final override class var component      : String { "Core" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "metadata" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @SFString public final var name      : String = ""
   @SFString public final var reference : String = ""
   @MFNode   public final var value     : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initMetadataObject ()

      types .append (.MetadataSet)

      addField (.inputOutput, "metadata",  $metadata)
      addField (.inputOutput, "name",      $name)
      addField (.inputOutput, "reference", $reference)
      addField (.inputOutput, "value",     $value)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> MetadataSet
   {
      return MetadataSet (with: executionContext)
   }
}
