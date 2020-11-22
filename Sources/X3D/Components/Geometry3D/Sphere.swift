//
//  Sphere.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public final class Sphere :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "Sphere" }
   internal final override class var component      : String { "Geometry3D" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }

   // Fields

   @SFFloat public final var radius : Float = 1
   @SFBool  public final var solid  : Bool = true

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.Sphere)

      addField (.inputOutput,    "metadata", $metadata)
      addField (.initializeOnly, "radius",   $radius)
      addField (.initializeOnly, "solid",    $solid)

      $radius .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> Sphere
   {
      return Sphere (with: executionContext)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      DispatchQueue .main .async
      {
         guard let browser = self .browser else { return }
         
         browser .sphereOptions .addInterest ("requestRebuild", Sphere .requestRebuild, self)
         
         self .rebuild ()
      }
   }
   
   // Build
   
   internal final override func makeBBox () -> Box3f
   {
      return Box3f (min: Vector3f (repeating: -radius),
                    max: Vector3f (repeating:  radius))
   }
   
   internal final override func build ()
   {
      guard let browser = browser else { return }
      
      isSolid     = solid
      hasTexCoord = true
      
      for vertex in browser .sphereOptions .primitives
      {
         addPrimitive (texCoords: [vertex .texCoord],
                       normal: vertex .point,
                       point: vertex .point * radius)
      }
   }
}
