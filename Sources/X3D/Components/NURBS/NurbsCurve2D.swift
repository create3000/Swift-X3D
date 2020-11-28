//
//  NurbsCurve2D.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class NurbsCurve2D :
   X3DNurbsControlCurveNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "NurbsCurve2D" }
   internal final override class var component      : String { "NURBS" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "children" }

   // Fields

   @SFInt32  public final var tessellation : Int32 = 0
   @SFBool   public final var closed       : Bool = false
   @SFInt32  public final var order        : Int32 = 3
   @MFDouble public final var knot         : [Double]
   @MFDouble public final var weight       : [Double]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.NurbsCurve2D)

      addField (.inputOutput,    "metadata",     $metadata)
      addField (.inputOutput,    "tessellation", $tessellation)
      addField (.initializeOnly, "closed",       $closed)
      addField (.initializeOnly, "order",        $order)
      addField (.initializeOnly, "knot",         $knot)
      addField (.inputOutput,    "weight",       $weight)
      addField (.inputOutput,    "controlPoint", $controlPoint)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NurbsCurve2D
   {
      return NurbsCurve2D (with: executionContext)
   }
}
