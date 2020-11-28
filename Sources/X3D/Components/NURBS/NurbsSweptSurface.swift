//
//  NurbsSweptSurface.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class NurbsSweptSurface :
   X3DParametricGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "NurbsSweptSurface" }
   internal final override class var component      : String { "NURBS" }
   internal final override class var componentLevel : Int32 { 3 }
   internal final override class var containerField : String { "geometry" }

   // Fields

   @SFBool public final var solid             : Bool = true
   @SFBool public final var ccw               : Bool = true
   @SFNode public final var crossSectionCurve : X3DNode?
   @SFNode public final var trajectoryCurve   : X3DNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.NurbsSweptSurface)

      addField (.inputOutput,    "metadata",          $metadata)
      addField (.initializeOnly, "solid",             $solid)
      addField (.initializeOnly, "ccw",               $ccw)
      addField (.inputOutput,    "crossSectionCurve", $crossSectionCurve)
      addField (.inputOutput,    "trajectoryCurve",   $trajectoryCurve)
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> NurbsSweptSurface
   {
      return NurbsSweptSurface (with: executionContext)
   }
}
