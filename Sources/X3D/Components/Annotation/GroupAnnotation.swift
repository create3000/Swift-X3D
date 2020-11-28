//
//  GroupAnnotation.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class GroupAnnotation :
   X3DGroupingNode,
   X3DAnnotationNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "GroupAnnotation" }
   internal final override class var component      : String { "Annotation" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   
   // Fields
   
   @SFBool   public final var enabled           : Bool = true
   @SFString public final var annotationGroupID : String = ""
   @SFString public final var displayPolicy     : String = "NEVER"

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initAnnotationNode ()

      types .append (.GroupAnnotation)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.inputOutput,    "enabled",           $enabled)
      addField (.inputOutput,    "annotationGroupID", $annotationGroupID)
      addField (.inputOutput,    "displayPolicy",     $displayPolicy)
      addField (.initializeOnly, "bboxCenter",        $bboxCenter)
      addField (.initializeOnly, "bboxSize",          $bboxSize)
      addField (.inputOnly,      "addChildren",       $addChildren)
      addField (.inputOnly,      "removeChildren",    $removeChildren)
      addField (.inputOutput,    "children",          $children)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> GroupAnnotation
   {
      return GroupAnnotation (with: executionContext)
   }
}
