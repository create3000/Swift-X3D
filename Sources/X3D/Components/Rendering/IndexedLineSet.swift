//
//  IndexedLineSet.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public final class IndexedLineSet :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   internal final override class var typeName       : String { "IndexedLineSet" }
   internal final override class var component      : String { "Rendering" }
   internal final override class var componentLevel : Int32 { 1 }
   internal final override class var containerField : String { "geometry" }

   // Fields

   @MFInt32 public final var set_colorIndex : [Int32]
   @MFInt32 public final var set_coordIndex : [Int32]
   @SFBool  public final var colorPerVertex : Bool = true
   @MFInt32 public final var colorIndex     : [Int32]
   @MFInt32 public final var coordIndex     : [Int32]
   @MFNode  public final var attrib         : [X3DNode?]
   @SFNode  public final var fogCoord       : X3DNode?
   @SFNode  public final var color          : X3DNode?
   @SFNode  public final var coord          : X3DNode?
   @SFNode  public final var options        : X3DNode?

   // Properties
   
   @MFNode private final var attribNodes  : [X3DVertexAttributeNode?]
   @SFNode private final var fogCoordNode : FogCoordinate?
   @SFNode private final var colorNode    : X3DColorNode?
   @SFNode private final var coordNode    : X3DCoordinateNode?

   // Construction
   
   internal init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.IndexedLineSet)

      addField (.inputOutput,    "metadata",       $metadata)
      addField (.inputOnly,      "set_colorIndex", $set_colorIndex)
      addField (.inputOnly,      "set_coordIndex", $set_coordIndex)
      addField (.initializeOnly, "colorPerVertex", $colorPerVertex)
      addField (.initializeOnly, "colorIndex",     $colorIndex)
      addField (.initializeOnly, "coordIndex",     $coordIndex)
      addField (.inputOutput,    "attrib",         $attrib)
      addField (.inputOutput,    "fogCoord",       $fogCoord)
      addField (.inputOutput,    "color",          $color)
      addField (.inputOutput,    "coord",          $coord)
      
      addChildObjects ($attribNodes,
                       $fogCoordNode,
                       $colorNode,
                       $coordNode)

      geometryType  = 1
      primitiveType = .line
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> IndexedLineSet
   {
      return IndexedLineSet (with: executionContext)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $set_colorIndex .addFieldInterest (to: $colorIndex)
      $set_coordIndex .addFieldInterest (to: $coordIndex)

      $attrib   .addInterest ("set_attrib",   IndexedLineSet .set_attrib,   self)
      $fogCoord .addInterest ("set_fogCoord", IndexedLineSet .set_fogCoord, self)
      $color    .addInterest ("set_color",    IndexedLineSet .set_color,    self)
      $coord    .addInterest ("set_coord",    IndexedLineSet .set_coord,    self)

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
      fogCoordNode? .removeInterest ("requestRebuild", IndexedLineSet .requestRebuild, self)
      
      fogCoordNode = fogCoord? .innerNode as? FogCoordinate
      
      fogCoordNode? .addInterest ("requestRebuild", IndexedLineSet .requestRebuild, self)
   }
   
   private final func set_color ()
   {
      if colorNode != nil
      {
         colorNode! .removeInterest ("requestRebuild", IndexedLineSet .requestRebuild, self)
         colorNode! .$isTransparent .removeFieldInterest (to: $isTransparent)
      }

      colorNode = color? .innerNode as? X3DColorNode

      if colorNode != nil
      {
         colorNode! .addInterest ("requestRebuild", IndexedLineSet .requestRebuild, self)
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
      coordNode? .removeInterest ("requestRebuild", IndexedLineSet .requestRebuild, self)
      
      coordNode = coord? .innerNode as? X3DCoordinateNode
      
      coordNode? .addInterest ("requestRebuild", IndexedLineSet .requestRebuild, self)
   }

   // Build
   
   private final func getColorIndex (i : Int) -> Int
   {
      return Int (colorIndex .indices .contains (i) ? colorIndex [i] : coordIndex [i])
   }

   private final func getColorIndex (face : Int) -> Int
   {
      return colorIndex .indices .contains (face) ? Int (colorIndex [face]) : face
   }

   internal final override func build ()
   {
      guard let coordNode = coordNode else { return }
      
      hasFogCoord = fogCoordNode != nil
      hasColor    = colorNode    != nil

      let polylines = makePolylines ()

      // Fill GeometryNode

      var fogDepth = Float (0)
      var color    = Color4f .one
      var face     = 0

      for polyline in polylines
      {
         // Create two vertices for each line.

         if polyline .count > 1
         {
            for line in 0 ..< polyline .count - 1
            {
               for p in line ..< line + 2
               {
                  let i     = polyline [p]
                  let index = Int (coordIndex [i])

                  if let fogCoordNode = fogCoordNode
                  {
                     fogDepth = fogCoordNode .get1Depth (at: index)
                  }

                  if let colorNode = colorNode
                  {
                     if colorPerVertex
                     {
                        color = colorNode .get1Color (at: getColorIndex (i: i))
                     }
                     else
                     {
                        color = colorNode .get1Color (at: getColorIndex (face: face))
                     }
                  }
                  
                  let point = coordNode .get1Point (at: index)
                 
                  addPrimitive (fogDepth: fogDepth,
                                color: color,
                                point: point)
               }
            }
         }

         face += 1
      }
   }

   private final func makePolylines () -> [[Int]]
   {
      guard !coordIndex .isEmpty else { return [ ] }
      
      var polylines = [[Int]] ()
      var polyline  = [Int] ()

      for i in 0 ..< coordIndex .count
      {
         if coordIndex [i] >= 0
         {
            // Add vertex.
            polyline .append (i)
         }
         else
         {
            // Negativ index.
            // Add polylines.
            polylines .append (polyline)
            polyline .removeAll (keepingCapacity: true)
         }
      }

      if coordIndex .last! >= 0
      {
         polylines .append (polyline)
      }

      return polylines
   }
   
   // Rendering
   
   internal final override func render (_ context : RenderContext, _ renderEncoder : MTLRenderCommandEncoder)
   {
      renderLines (context, renderEncoder)
   }
}
