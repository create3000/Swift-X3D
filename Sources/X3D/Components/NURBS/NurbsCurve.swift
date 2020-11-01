//
//  NurbsCurve.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class NurbsCurve :
   X3DParametricGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "NurbsCurve" }
   public final override class var component      : String { "NURBS" }
   public final override class var componentLevel : Int32 { 3 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @SFBool   public final var closed       : Bool = false
   @SFInt32  public final var tessellation : Int32 = 0
   @SFInt32  public final var order        : Int32 = 3
   @MFDouble public final var knot         : MFDouble .Value
   @MFDouble public final var weight       : MFDouble .Value
   @SFNode   public final var controlPoint : X3DNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.NurbsCurve)

      addField (.inputOutput,    "metadata",     $metadata)
      addField (.initializeOnly, "closed",       $closed)
      addField (.inputOutput,    "tessellation", $tessellation)
      addField (.initializeOnly, "order",        $order)
      addField (.initializeOnly, "knot",         $knot)
      addField (.inputOutput,    "weight",       $weight)
      addField (.inputOutput,    "controlPoint", $controlPoint)
      
      geometryType  = 1
      primitiveType = .line
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NurbsCurve
   {
      return NurbsCurve (with: executionContext)
   }
}
