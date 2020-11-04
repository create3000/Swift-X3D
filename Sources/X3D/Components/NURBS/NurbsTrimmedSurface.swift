//
//  NurbsTrimmedSurface.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class NurbsTrimmedSurface :
   X3DNurbsSurfaceGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "NurbsTrimmedSurface" }
   public final override class var component      : String { "NURBS" }
   public final override class var componentLevel : Int32 { 4 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @MFNode public final var addTrimmingContour    : MFNode <X3DNode> .Value
   @MFNode public final var removeTrimmingContour : MFNode <X3DNode> .Value
   @MFNode public final var trimmingContour       : MFNode <X3DNode> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.NurbsTrimmedSurface)

      addField (.inputOutput,    "metadata",              $metadata)
      addField (.initializeOnly, "solid",                 $solid)
      addField (.inputOutput,    "uTessellation",         $uTessellation)
      addField (.inputOutput,    "vTessellation",         $vTessellation)
      addField (.initializeOnly, "uClosed",               $uClosed)
      addField (.initializeOnly, "vClosed",               $vClosed)
      addField (.initializeOnly, "uOrder",                $uOrder)
      addField (.initializeOnly, "vOrder",                $vOrder)
      addField (.initializeOnly, "uDimension",            $uDimension)
      addField (.initializeOnly, "vDimension",            $vDimension)
      addField (.initializeOnly, "uKnot",                 $uKnot)
      addField (.initializeOnly, "vKnot",                 $vKnot)
      addField (.inputOutput,    "weight",                $weight)
      addField (.inputOutput,    "texCoord",              $texCoord)
      addField (.inputOutput,    "controlPoint",          $controlPoint)
      addField (.inputOnly,      "addTrimmingContour",    $addTrimmingContour)
      addField (.inputOnly,      "removeTrimmingContour", $removeTrimmingContour)
      addField (.inputOutput,    "trimmingContour",       $trimmingContour)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NurbsTrimmedSurface
   {
      return NurbsTrimmedSurface (with: executionContext)
   }
}