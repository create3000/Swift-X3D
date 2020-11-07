//
//  AnnotationTarget.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class AnnotationTarget :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "AnnotationTarget" }
   internal final override class var component      : String { "Annotation" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFVec3f public final var referencePoint : Vector3f = Vector3f (0, 0, 0)
   @SFNode  public final var leadLineStyle  : X3DNode?
   @SFNode  public final var marker         : X3DNode?
   @MFNode  public final var annotations    : MFNode <X3DNode> .Value

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.AnnotationTarget)

      addField (.inputOutput, "metadata",       $metadata)
      addField (.inputOutput, "referencePoint", $referencePoint)
      addField (.inputOutput, "leadLineStyle",  $leadLineStyle)
      addField (.inputOutput, "marker",         $marker)
      addField (.inputOutput, "annotations",    $annotations)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> AnnotationTarget
   {
      return AnnotationTarget (with: executionContext)
   }
}
