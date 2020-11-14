//
//  NurbsTextureCoordinate.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class NurbsTextureCoordinate :
   X3DNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "NurbsTextureCoordinate" }
   internal final override class var component      : String { "NURBS" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "texCoord" }

   // Fields

   @SFInt32  public final var uOrder       : Int32 = 3
   @SFInt32  public final var vOrder       : Int32 = 3
   @SFInt32  public final var uDimension   : Int32 = 0
   @SFInt32  public final var vDimension   : Int32 = 0
   @MFDouble public final var uKnot        : [Double]
   @MFDouble public final var vKnot        : [Double]
   @MFFloat  public final var weight       : [Float]
   @MFVec2f  public final var controlPoint : [Vector2f]

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.NurbsTextureCoordinate)

      addField (.inputOutput,    "metadata",     $metadata)
      addField (.initializeOnly, "uOrder",       $uOrder)
      addField (.initializeOnly, "vOrder",       $vOrder)
      addField (.initializeOnly, "uDimension",   $uDimension)
      addField (.initializeOnly, "vDimension",   $vDimension)
      addField (.initializeOnly, "uKnot",        $uKnot)
      addField (.initializeOnly, "vKnot",        $vKnot)
      addField (.inputOutput,    "weight",       $weight)
      addField (.inputOutput,    "controlPoint", $controlPoint)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NurbsTextureCoordinate
   {
      return NurbsTextureCoordinate (with: executionContext)
   }
}
