//
//  TextAnnotation.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class TextAnnotation :
   X3DChildNode,
   X3DAnnotationNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "TextAnnotation" }
   internal final override class var component      : String { "Annotation" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields
   
   @SFBool   public final var enabled           : Bool = true
   @SFString public final var annotationGroupID : String = ""
   @SFString public final var displayPolicy     : String = "NEVER"
   @SFString public final var contentType       : String = "text/plain"
   @SFString public final var text              : String = ""

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initAnnotationNode ()

      types .append (.TextAnnotation)

      addField (.inputOutput, "metadata",          $metadata)
      addField (.inputOutput, "enabled",           $enabled)
      addField (.inputOutput, "annotationGroupID", $annotationGroupID)
      addField (.inputOutput, "displayPolicy",     $displayPolicy)
      addField (.inputOutput, "contentType",       $contentType)
      addField (.inputOutput, "text",              $text)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> TextAnnotation
   {
      return TextAnnotation (with: executionContext)
   }
}
