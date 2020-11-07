//
//  NurbsPatchSurface.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class NurbsPatchSurface :
   X3DNurbsSurfaceGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "NurbsPatchSurface" }
   internal final override class var component      : String { "NURBS" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.NurbsPatchSurface)

      addField (.inputOutput,    "metadata",      $metadata)
      addField (.initializeOnly, "solid",         $solid)
      addField (.inputOutput,    "uTessellation", $uTessellation)
      addField (.inputOutput,    "vTessellation", $vTessellation)
      addField (.initializeOnly, "uClosed",       $uClosed)
      addField (.initializeOnly, "vClosed",       $vClosed)
      addField (.initializeOnly, "uOrder",        $uOrder)
      addField (.initializeOnly, "vOrder",        $vOrder)
      addField (.initializeOnly, "uDimension",    $uDimension)
      addField (.initializeOnly, "vDimension",    $vDimension)
      addField (.initializeOnly, "uKnot",         $uKnot)
      addField (.initializeOnly, "vKnot",         $vKnot)
      addField (.inputOutput,    "weight",        $weight)
      addField (.inputOutput,    "texCoord",      $texCoord)
      addField (.inputOutput,    "controlPoint",  $controlPoint)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NurbsPatchSurface
   {
      return NurbsPatchSurface (with: executionContext)
   }
}
