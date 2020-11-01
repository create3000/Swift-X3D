//
//  PointSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class PointSet :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "PointSet" }
   public final override class var component      : String { "Rendering" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @MFNode public final var attrib   : MFNode <X3DNode> .Value
   @SFNode public final var fogCoord : X3DNode?
   @SFNode public final var color    : X3DNode?
   @SFNode public final var coord    : X3DNode?

   // Properties
   
   @MFNode private final var attribNodes  : MFNode <X3DVertexAttributeNode> .Value
   @SFNode private final var fogCoordNode : FogCoordinate?
   @SFNode private final var colorNode    : X3DColorNode?
   @SFNode private final var coordNode    : X3DCoordinateNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.PointSet)

      addField (.inputOutput, "metadata", $metadata)
      addField (.inputOutput, "attrib",   $attrib)
      addField (.inputOutput, "fogCoord", $fogCoord)
      addField (.inputOutput, "color",    $color)
      addField (.inputOutput, "coord",    $coord)
      
      addChildObjects ($attribNodes,
                       $fogCoordNode,
                       $colorNode,
                       $coordNode)

      geometryType  = 1
      primitiveType = .point
  }

   internal final override func create (with executionContext : X3DExecutionContext) -> PointSet
   {
      return PointSet (with: executionContext)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $attrib   .addInterest (PointSet .set_attrib,   self)
      $fogCoord .addInterest (PointSet .set_fogCoord, self)
      $color    .addInterest (PointSet .set_color,    self)
      $coord    .addInterest (PointSet .set_coord,    self)

      set_attrib ()
      set_fogCoord ()
      set_color ()
      set_coord ()
      
      rebuild ()
   }

   // Event handlers
   
   private final func set_attrib ()
   {
      
   }

   private final func set_fogCoord ()
   {
      fogCoordNode? .removeInterest (PointSet .requestRebuild, self)
      
      fogCoordNode = fogCoord? .innerNode as? FogCoordinate
      
      fogCoordNode? .addInterest (PointSet .requestRebuild, self)
   }
   
   private final func set_color ()
   {
      if colorNode != nil
      {
         colorNode! .removeInterest (PointSet .requestRebuild, self)
         colorNode! .$isTransparent .removeFieldInterest (to: $isTransparent)
      }

      colorNode = color? .innerNode as? X3DColorNode

      if colorNode != nil
      {
         colorNode! .addInterest (PointSet .requestRebuild, self)
         colorNode! .$isTransparent .addFieldInterest (to: $isTransparent)
         
         setTransparent (colorNode! .isTransparent)
      }
      else
      {
         setTransparent (false)
      }
   }
   
   private final func set_coord ()
   {
      coordNode? .removeInterest (PointSet .requestRebuild, self)
      
      coordNode = coord? .innerNode as? X3DCoordinateNode
      
      coordNode? .addInterest (PointSet .requestRebuild, self)
   }

   // Build
   
   internal final override func build ()
   {
      guard let coordNode = coordNode else { return }
      
      hasFogCoord = fogCoordNode != nil
      hasColor    = colorNode != nil
      
      var fogDepth = Float (0)
      var color    = Color4f .one
      
      for index in 0 ..< coordNode .count
      {
         if let fogCoordNode = fogCoordNode
         {
            fogDepth = fogCoordNode .get1Depth (at: index)
         }
         
         if let colorNode = colorNode
         {
            color = colorNode .get1Color (at: index)
         }
         
         addPrimitive (fogDepth: fogDepth,
                       color: color,
                       point: coordNode .get1Point (at: index))
      }
   }
   
   // Rendering
   
   internal final override func render (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      renderPoints (context, renderEncoder)
   }
}
