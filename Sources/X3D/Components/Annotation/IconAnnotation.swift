//
//  IconAnnotation.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class IconAnnotation :
   X3DChildNode,
   X3DAnnotationNode,
   X3DUrlObject,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "IconAnnotation" }
   internal final override class var component      : String { "Annotation" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields
   
   @SFBool   public final var enabled           : Bool = true
   @SFString public final var annotationGroupID : String = ""
   @SFString public final var displayPolicy     : String = "NEVER"
   @MFString public final var url               : MFString .Value
   
   // X3DUrlObject
   
   @SFEnum public final var loadState : X3DLoadState = .NOT_STARTED_STATE

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      initAnnotationNode ()
      initUrlObject ()

      types .append (.IconAnnotation)

      addField (.inputOutput, "metadata",          $metadata)
      addField (.inputOutput, "enabled",           $enabled)
      addField (.inputOutput, "annotationGroupID", $annotationGroupID)
      addField (.inputOutput, "displayPolicy",     $displayPolicy)
      addField (.inputOutput, "url",               $url)
      
      addChildObjects ($loadState)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> IconAnnotation
   {
      return IconAnnotation (with: executionContext)
   }
   
   public final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
   }
}
