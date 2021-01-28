//
//  LineSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class LineSet :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "LineSet" }
   internal final override class var component      : String { "Rendering" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }
   internal final override class var implemented    : Implemented { (sunrise: true, x_ite: true) }

   // Fields

   @MFInt32 public final var vertexCount : [Int32]
   @MFNode  public final var attrib      : [X3DNode?]
   @SFNode  public final var fogCoord    : X3DNode?
   @SFNode  public final var color       : X3DNode?
   @SFNode  public final var coord       : X3DNode?

   // Properties
   
   private final var attribNodes  : [X3DVertexAttributeNode] = [ ]
   private final var fogCoordNode : FogCoordinate?
   private final var colorNode    : X3DColorNode?
   private final var coordNode    : X3DCoordinateNode?

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      types .append (.LineSet)
      
      addField (.inputOutput, "metadata",    $metadata)
      addField (.inputOutput, "vertexCount", $vertexCount)
      addField (.inputOutput, "attrib",      $attrib)
      addField (.inputOutput, "fogCoord",    $fogCoord)
      addField (.inputOutput, "color",       $color)
      addField (.inputOutput, "coord",       $coord)

      geometryType  = 1
      primitiveType = .line
  }

   internal final override func create (with executionContext : X3DExecutionContext) -> LineSet
   {
      return LineSet (with: executionContext)
   }
   
   internal override func initialize ()
   {
      super .initialize ()

      $attrib   .addInterest ("set_attrib",   { $0 .set_attrib () },   self)
      $fogCoord .addInterest ("set_fogCoord", { $0 .set_fogCoord () }, self)
      $color    .addInterest ("set_color",    { $0 .set_color () },    self)
      $coord    .addInterest ("set_coord",    { $0 .set_coord () },    self)

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
      fogCoordNode? .removeInterest ("requestRebuild", self)
      
      fogCoordNode = fogCoord? .innerNode as? FogCoordinate
      
      fogCoordNode? .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
   }
   
   private final func set_color ()
   {
      if colorNode != nil
      {
         colorNode! .removeInterest ("requestRebuild", self)
         colorNode! .$isTransparent .removeFieldInterest (to: $isTransparent)
      }

      colorNode = color? .innerNode as? X3DColorNode

      if colorNode != nil
      {
         colorNode! .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
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
      coordNode? .removeInterest ("requestRebuild", self)
      
      coordNode = coord? .innerNode as? X3DCoordinateNode
      
      coordNode? .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
   }

   // Build
   
   internal final override func build ()
   {
      guard let coordNode = coordNode else { return }
      
      hasFogCoord = fogCoordNode != nil
      hasColor    = colorNode != nil
      
      var fogDepth = Float (0)
      var color    = Color4f .one
      var index    = 0

      for count in vertexCount
      {
         guard index + Int (count) <= coordNode .count else { break }

         if count > 1
         {
            for i in 1 ... 2 * Int (count) - 2
            {
               if let fogCoordNode = fogCoordNode
               {
                  fogDepth = fogCoordNode .get1Depth (at: index)
               }

               if let colorNode = colorNode
               {
                  color = colorNode .get1Color (at: index)
               }

               let point = coordNode .get1Point (at: index)
              
               addPrimitive (fogDepth: fogDepth,
                             color: color,
                             point: point)

               index += i & 1
            }

            index += 1
         }
         else
         {
            index += Int (count)
         }
      }
   }
   
   // Rendering
   
   internal final override func render (_ context : RenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      renderLines (context, renderEncoder)
   }
}
