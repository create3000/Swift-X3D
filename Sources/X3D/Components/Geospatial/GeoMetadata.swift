//
//  GeoMetadata.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GeoMetadata :
   X3DInfoNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "GeoMetadata" }
   internal final override class var component      : String { "Geospatial" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @MFString public final var url     : [String]
   @MFString public final var summary : [String]
   @MFNode   public final var data    : [X3DNode?]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.GeoMetadata)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "url",      $url)
      addField (.inputOutput, "summary",  $summary)
      addField (.inputOutput, "data",     $data)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GeoMetadata
   {
      return GeoMetadata (with: executionContext)
   }
}
