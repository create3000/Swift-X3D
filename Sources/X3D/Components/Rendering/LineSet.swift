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
   
   public final override class var typeName       : String { "LineSet" }
   public final override class var component      : String { "Rendering" }
   public final override class var componentLevel : Int32 { 1 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @MFInt32 public final var vertexCount : MFInt32 .Value
   @MFNode  public final var attrib      : MFNode <X3DNode> .Value
   @SFNode  public final var fogCoord    : X3DNode?
   @SFNode  public final var color       : X3DNode?
   @SFNode  public final var coord       : X3DNode?

   // Properties
   
   @MFNode private final var attribNodes  : MFNode <X3DVertexAttributeNode> .Value
   @SFNode private final var fogCoordNode : FogCoordinate?
   @SFNode private final var colorNode    : X3DColorNode?
   @SFNode private final var coordNode    : X3DCoordinateNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)
      
      types .append (.LineSet)
      
      addField (.inputOutput, "metadata",    $metadata)
      addField (.inputOutput, "vertexCount", $vertexCount)
      addField (.inputOutput, "attrib",      $attrib)
      addField (.inputOutput, "fogCoord",    $fogCoord)
      addField (.inputOutput, "color",       $color)
      addField (.inputOutput, "coord",       $coord)
      
      addChildObjects ($attribNodes,
                       $fogCoordNode,
                       $colorNode,
                       $coordNode)

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

      $attrib   .addInterest (LineSet .set_attrib,   self)
      $fogCoord .addInterest (LineSet .set_fogCoord, self)
      $color    .addInterest (LineSet .set_color,    self)
      $coord    .addInterest (LineSet .set_coord,    self)

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
      fogCoordNode? .removeInterest (LineSet .requestRebuild, self)
      
      fogCoordNode = fogCoord? .innerNode as? FogCoordinate
      
      fogCoordNode? .addInterest (LineSet .requestRebuild, self)
   }
   
   private final func set_color ()
   {
      if colorNode != nil
      {
         colorNode! .removeInterest (LineSet .requestRebuild, self)
         colorNode! .$isTransparent .removeFieldInterest (to: $isTransparent)
      }

      colorNode = color? .innerNode as? X3DColorNode

      if colorNode != nil
      {
         colorNode! .addInterest (LineSet .requestRebuild, self)
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
      coordNode? .removeInterest (LineSet .requestRebuild, self)
      
      coordNode = coord? .innerNode as? X3DCoordinateNode
      
      coordNode? .addInterest (LineSet .requestRebuild, self)
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
   
   internal final override func render (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      renderLines (context, renderEncoder)
   }
}
