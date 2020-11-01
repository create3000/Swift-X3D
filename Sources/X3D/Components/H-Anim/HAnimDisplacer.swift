//
//  HAnimDisplacer.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class HAnimDisplacer :
   X3DGeometricPropertyNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "HAnimDisplacer" }
   public final override class var component      : String { "H-Anim" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "displacers" }

   // Fields

   @SFString public final var name          : String = ""
   @MFInt32  public final var coordIndex    : MFInt32 .Value
   @SFFloat  public final var weight        : Float = 0
   @MFVec3f  public final var displacements : MFVec3f .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.HAnimDisplacer)

      addField (.inputOutput, "metadata",      $metadata)
      addField (.inputOutput, "name",          $name)
      addField (.inputOutput, "coordIndex",    $coordIndex)
      addField (.inputOutput, "weight",        $weight)
      addField (.inputOutput, "displacements", $displacements)

      $displacements .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> HAnimDisplacer
   {
      return HAnimDisplacer (with: executionContext)
   }
}
