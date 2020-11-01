//
//  MetadataBoolean.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class MetadataBoolean :
   X3DNode,
   X3DMetadataObject,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "MetadataBoolean" }
   public final override class var component      : String { "Core" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "metadata" }

   // Fields

   @SFString public final var name      : String = ""
   @SFString public final var reference : String = ""
   @MFBool   public final var value     : MFBool .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initMetadataObject ()

      types .append (.MetadataBoolean)

      addField (.inputOutput, "metadata",  $metadata)
      addField (.inputOutput, "name",      $name)
      addField (.inputOutput, "reference", $reference)
      addField (.inputOutput, "value",     $value)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> MetadataBoolean
   {
      return MetadataBoolean (with: executionContext)
   }
}
