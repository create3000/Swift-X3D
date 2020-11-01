//
//  ElevationGrid.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ElevationGrid :
   X3DGeometryNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ElevationGrid" }
   public final override class var component      : String { "Geometry3D" }
   public final override class var componentLevel : Int32 { 3 }
   public final override class var containerField : String { "geometry" }

   // Fields

   @MFFloat public final var set_height      : MFFloat .Value
   @SFInt32 public final var xDimension      : Int32 = 0
   @SFInt32 public final var zDimension      : Int32 = 0
   @SFFloat public final var xSpacing        : Float = 1
   @SFFloat public final var zSpacing        : Float = 1
   @SFBool  public final var solid           : Bool = true
   @SFBool  public final var ccw             : Bool = true
   @SFFloat public final var creaseAngle     : Float = 0
   @SFBool  public final var colorPerVertex  : Bool = true
   @SFBool  public final var normalPerVertex : Bool = true
   @MFNode  public final var attrib          : MFNode <X3DNode> .Value
   @SFNode  public final var fogCoord        : X3DNode?
   @SFNode  public final var color           : X3DNode?
   @SFNode  public final var texCoord        : X3DNode?
   @SFNode  public final var normal          : X3DNode?
   @MFFloat public final var height          : MFFloat .Value

   // Properties
   
   @MFNode private final var attribNodes  : MFNode <X3DVertexAttributeNode> .Value
   @SFNode private final var fogCoordNode : FogCoordinate?
   @SFNode private final var colorNode    : X3DColorNode?
   @SFNode private final var texCoordNode : X3DTextureCoordinateNode?
   @SFNode private final var normalNode   : X3DNormalNode?

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      super .init (executionContext .browser!, executionContext)

      types .append (.ElevationGrid)

      addField (.inputOutput,    "metadata",        $metadata)
      addField (.inputOnly,      "set_height",      $set_height)
      addField (.initializeOnly, "xDimension",      $xDimension)
      addField (.initializeOnly, "zDimension",      $zDimension)
      addField (.initializeOnly, "xSpacing",        $xSpacing)
      addField (.initializeOnly, "zSpacing",        $zSpacing)
      addField (.initializeOnly, "solid",           $solid)
      addField (.initializeOnly, "ccw",             $ccw)
      addField (.initializeOnly, "creaseAngle",     $creaseAngle)
      addField (.initializeOnly, "colorPerVertex",  $colorPerVertex)
      addField (.initializeOnly, "normalPerVertex", $normalPerVertex)
      addField (.inputOutput,    "attrib",          $attrib)
      addField (.inputOutput,    "fogCoord",        $fogCoord)
      addField (.inputOutput,    "color",           $color)
      addField (.inputOutput,    "texCoord",        $texCoord)
      addField (.inputOutput,    "normal",          $normal)
      addField (.initializeOnly, "height",          $height)
      
      addChildObjects ($attribNodes,
                       $fogCoordNode,
                       $colorNode,
                       $texCoordNode,
                       $normalNode)

      $xSpacing    .unit = .length
      $zSpacing    .unit = .length
      $creaseAngle .unit = .angle
      $height      .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ElevationGrid
   {
      return ElevationGrid (with: executionContext)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $set_height .addFieldInterest (to: $height)

      $attrib   .addInterest (ElevationGrid .set_attrib,   self)
      $fogCoord .addInterest (ElevationGrid .set_fogCoord, self)
      $color    .addInterest (ElevationGrid .set_color,    self)
      $texCoord .addInterest (ElevationGrid .set_texCoord, self)
      $normal   .addInterest (ElevationGrid .set_normal,   self)

      set_attrib ()
      set_fogCoord ()
      set_color ()
      set_texCoord ()
      set_normal ()
      
      rebuild ()
   }

   // Event handlers
   
   private final func set_attrib ()
   {
      
   }

   private final func set_fogCoord ()
   {
      fogCoordNode? .removeInterest (ElevationGrid .requestRebuild, self)
      
      fogCoordNode = fogCoord? .innerNode as? FogCoordinate
      
      fogCoordNode? .addInterest (ElevationGrid .requestRebuild, self)
   }
   
   private final func set_color ()
   {
      if colorNode != nil
      {
         colorNode! .removeInterest (ElevationGrid .requestRebuild, self)
         colorNode! .$isTransparent .removeFieldInterest (to: $isTransparent)
      }

      colorNode = color? .innerNode as? X3DColorNode

      if colorNode != nil
      {
         colorNode! .addInterest (ElevationGrid .requestRebuild, self)
         colorNode! .$isTransparent .addFieldInterest (to: $isTransparent)
         
         setTransparent (colorNode! .isTransparent)
      }
      else
      {
         setTransparent (false)
      }
   }

   private final func set_texCoord ()
   {
      texCoordNode? .removeInterest (ElevationGrid .requestRebuild, self)
      
      texCoordNode = texCoord? .innerNode as? X3DTextureCoordinateNode
      
      texCoordNode? .addInterest (ElevationGrid .requestRebuild, self)
   }
   
   private final func set_normal ()
   {
      normalNode? .removeInterest (ElevationGrid .requestRebuild, self)
      
      normalNode = normal? .innerNode as? X3DNormalNode
      
      normalNode? .addInterest (ElevationGrid .requestRebuild, self)
   }

   // Build
   
   private final func getHeight (at index : Int) -> Float
   {
      return height .indices .contains (index) ? height [index] : 0
   }
   
   private final func makeTexCoords () -> [Vector4f]
   {
      var texCoords  = [Vector4f] ()
      let xSize      = Float (xDimension - 1)
      let zSize      = Float (zDimension - 1)

      for z in 0 ..< zDimension
      {
         for x in 0 ..< xDimension
         {
            texCoords .append (Vector4f (Float (x) / xSize, Float (z) / zSize, 0, 1))
         }
      }

      return texCoords
   }
   
   private final func makeNormals (points : [Vector3f], coordIndex : [Int]) -> [Vector3f]
   {
      var normalIndex = NormalIndex ()
      var faceNormals = Normals ()

      for c in stride (from: 0, to: coordIndex .count - 1, by: 3)
      {
         let c0 = coordIndex [c]
         let c1 = coordIndex [c + 1]
         let c2 = coordIndex [c + 2]

         normalIndex [c0, default: [ ]] .append (faceNormals .count)
         normalIndex [c1, default: [ ]] .append (faceNormals .count + 1)
         normalIndex [c2, default: [ ]] .append (faceNormals .count + 2)

         let n = X3D .normal (points [c0], points [c1], points [c2])

         faceNormals .append (n)
         faceNormals .append (n)
         faceNormals .append (n)
      }
      
      if !ccw
      {
         for i in 0 ..< faceNormals .count
         {
            faceNormals [i] = -faceNormals [i]
         }
      }

      return generateNormals (normalIndex: normalIndex, faceNormals: faceNormals, creaseAngle: creaseAngle)
   }
   
   private final func makeCoordIndex () -> [Int]
   {
      // p1 - p4
      //  | \ |
      // p2 - p3

      var coordIndex = [Int] ()
      let xSize      = xDimension - 1
      let zSize      = zDimension - 1

      for z in 0 ..< zSize
      {
         for x in 0 ..< xSize
         {
            let i1 = Int (      z * xDimension + x)
            let i2 = Int ((z + 1) * xDimension + x)
            let i3 = Int ((z + 1) * xDimension + (x + 1))
            let i4 = Int (      z * xDimension + (x + 1))

            coordIndex .append (i1) // p1
            coordIndex .append (i2) // p2
            coordIndex .append (i3) // p3

            coordIndex .append (i1) // p1
            coordIndex .append (i3) // p3
            coordIndex .append (i4) // p4
         }
      }

      return coordIndex
   }
   
   private final func makePoints () -> [Vector3f]
   {
      var points = [Vector3f] ()

      for z in 0 ..< zDimension
      {
         for x in 0 ..< xDimension
         {
            points .append (Vector3f (xSpacing * Float (x),
                                      getHeight (at: Int (x + z * xDimension)),
                                      zSpacing * Float (z)))
         }
      }

      return points
   }

   internal final override func build ()
   {
      guard xDimension > 1 && zDimension > 1 else { return }
      
      isSolid            = solid
      isCounterClockwise = ccw
      hasFogCoord        = fogCoordNode != nil
      hasColor           = colorNode != nil
      hasTexCoord        = true

      let texCoords  = texCoordNode == nil ? makeTexCoords () : [Vector4f] ()
      let coordIndex = makeCoordIndex ()
      let points     = makePoints ()
      let normals    = normalNode == nil ? makeNormals (points: points, coordIndex: coordIndex) : Normals ()
      var fogDepth   = Float (0)
      var color      = Color4f .one
      var texCoord   = [Vector4f] ()
      var normal     = Vector3f .zero
      var face       = 0
      
      for c in stride (from: 0, to: coordIndex .count, by: 6)
      {
         for p in 0 ..< 6
         {
            let i     = c + p
            let index = coordIndex [i]
            
            if let fogCoordNode = fogCoordNode
            {
               fogDepth = fogCoordNode .get1Depth (at: index)
            }

            if let colorNode = colorNode
            {
               if colorPerVertex
               {
                  color = colorNode .get1Color (at: index)
               }
               else
               {
                  color = colorNode .get1Color (at: face)
               }
            }

            texCoord .removeAll (keepingCapacity: true)
            
            if let texCoordNode = texCoordNode
            {
               texCoordNode .get1Point (at: index, array: &texCoord)
            }
            else
            {
               let t = texCoords [index]

               texCoord .append (Vector4f (t .x, t .y, 0, 1))
            }

            if let normalNode = normalNode
            {
               if normalPerVertex
               {
                  normal = normalNode .get1Vector (at: index)
               }
               else
               {
                  normal = normalNode .get1Vector (at: face)
               }
            }
            else
            {
               normal = normals [i]
            }

            addPrimitive (fogDepth: fogDepth,
                          color: color,
                          texCoords: texCoord,
                          normal: normal,
                          point: points [index])
         }
         
         face += 1
      }
   }
}
