//
//  ViewpointGroup.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ViewpointGroup :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ViewpointGroup" }
   public final override class var component      : String { "Navigation" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFString public final var description       : String = ""
   @SFBool   public final var displayed         : Bool = true
   @SFBool   public final var retainUserOffsets : Bool = false
   @SFVec3f  public final var size              : Vector3f = Vector3f .zero
   @SFVec3f  public final var center            : Vector3f = Vector3f .zero
   @MFNode   public final var children          : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ViewpointGroup)

      addField (.inputOutput, "metadata",          $metadata)
      addField (.inputOutput, "description",       $description)
      addField (.inputOutput, "displayed",         $displayed)
      addField (.inputOutput, "retainUserOffsets", $retainUserOffsets)
      addField (.inputOutput, "size",              $size)
      addField (.inputOutput, "center",            $center)
      addField (.inputOutput, "children",          $children)

      $size   .unit = .length
      $center .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ViewpointGroup
   {
      return ViewpointGroup (with: executionContext)
   }
}
