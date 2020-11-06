//
//  ClipPlane.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ClipPlane :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ClipPlane" }
   public final override class var component      : String { "Rendering" }
   public final override class var componentLevel : Int32 { 5 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFBool  public final var enabled : Bool = true
   @SFVec4f public final var plane   : Vector4f = Vector4f (0, 1, 0, 0)

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ClipPlane)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "enabled",  $enabled)
      addField (.inputOutput, "plane",    $plane)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ClipPlane
   {
      return ClipPlane (with: executionContext)
   }
}
