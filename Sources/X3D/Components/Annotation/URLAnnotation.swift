//
//  URLAnnotation.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class URLAnnotation :
   X3DChildNode,
   X3DAnnotationNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "URLAnnotation" }
   internal final override class var component      : String { "Annotation" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFBool   public final var enabled           : Bool = true
   @SFString public final var annotationGroupID : String = ""
   @SFString public final var displayPolicy     : String = "NEVER"
   @MFString public final var url               : [String]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initAnnotationNode ()

      types .append (.URLAnnotation)

      addField (.inputOutput, "metadata",          $metadata)
      addField (.inputOutput, "enabled",           $enabled)
      addField (.inputOutput, "annotationGroupID", $annotationGroupID)
      addField (.inputOutput, "displayPolicy",     $displayPolicy)
      addField (.inputOutput, "url",               $url)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> URLAnnotation
   {
      return URLAnnotation (with: executionContext)
   }
}
