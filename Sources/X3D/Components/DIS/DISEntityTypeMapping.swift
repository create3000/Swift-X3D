//
//  DISEntityTypeMapping.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class DISEntityTypeMapping :
   X3DInfoNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "DISEntityTypeMapping" }
   internal final override class var component      : String { "DIS" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "mapping" }

   // Fields

   @MFString public final var url         : [String]
   @SFInt32  public final var category    : Int32 = 0
   @SFInt32  public final var country     : Int32 = 0
   @SFInt32  public final var domain      : Int32 = 0
   @SFInt32  public final var extra       : Int32 = 0
   @SFInt32  public final var kind        : Int32 = 0
   @SFInt32  public final var specific    : Int32 = 0
   @SFInt32  public final var subcategory : Int32 = 0

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.DISEntityTypeMapping)

      addField (.inputOutput,    "metadata",    $metadata)
      addField (.inputOutput,    "url",         $url)
      addField (.initializeOnly, "category",    $category)
      addField (.initializeOnly, "country",     $country)
      addField (.initializeOnly, "domain",      $domain)
      addField (.initializeOnly, "extra",       $extra)
      addField (.initializeOnly, "kind",        $kind)
      addField (.initializeOnly, "specific",    $specific)
      addField (.initializeOnly, "subcategory", $subcategory)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> DISEntityTypeMapping
   {
      return DISEntityTypeMapping (with: executionContext)
   }
}
