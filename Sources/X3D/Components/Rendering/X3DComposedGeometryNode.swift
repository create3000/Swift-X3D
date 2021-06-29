//
//  X3DComposedGeometryNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DComposedGeometryNode :
   X3DGeometryNode
{
   // Fields

   @SFBool public final var colorPerVertex  : Bool = true
   @SFBool public final var normalPerVertex : Bool = true
   @SFBool public final var solid           : Bool = true
   @SFBool public final var ccw             : Bool = true
   @MFNode public final var attrib          : [X3DNode?]
   @SFNode public final var fogCoord        : X3DNode?
   @SFNode public final var color           : X3DNode?
   @SFNode public final var texCoord        : X3DNode?
   @SFNode public final var normal          : X3DNode?
   @SFNode public final var coord           : X3DNode?

   // Properties
   
   internal final var attribNodes  : [X3DVertexAttributeNode] = [ ]
   internal final var fogCoordNode : FogCoordinate?
   internal final var colorNode    : X3DColorNode?
   internal final var normalNode   : X3DNormalNode?
   internal final var coordNode    : X3DCoordinateNode?

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DComposedGeometryNode)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $attrib   .addInterest ("set_attrib",   { $0 .set_attrib () },   self)
      $fogCoord .addInterest ("set_fogCoord", { $0 .set_fogCoord () }, self)
      $color    .addInterest ("set_color",    { $0 .set_color () },    self)
      $texCoord .addInterest ("set_texCoord", { $0 .set_texCoord () }, self)
      $normal   .addInterest ("set_normal",   { $0 .set_normal () },   self)
      $coord    .addInterest ("set_coord",    { $0 .set_coord () },    self)

      set_attrib ()
      set_fogCoord ()
      set_color ()
      set_texCoord ()
      set_normal ()
      set_coord ()
   }
   
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

   private final func set_texCoord ()
   {
      texCoordNode? .removeInterest ("requestRebuild", self)
      
      texCoordNode = texCoord? .innerNode as? X3DTextureCoordinateNode ?? browser! .defaultTextureCoordinateNode
      
      texCoordNode? .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
   }
   
   private final func set_normal ()
   {
      normalNode? .removeInterest ("requestRebuild", self)
      
      normalNode = normal? .innerNode as? X3DNormalNode
      
      normalNode? .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
   }
   
   private final func set_coord ()
   {
      coordNode? .removeInterest ("requestRebuild", self)
      
      coordNode = coord? .innerNode as? X3DCoordinateNode
      
      coordNode? .addInterest ("requestRebuild", { $0 .requestRebuild () }, self)
   }
   
   // Build
   
   internal func getTriangleIndex (at index : Int) -> Int
   {
      return index
   }

   internal func getPolygonIndex (at index : Int) -> Int
   {
      return index
   }
   
   internal final func build (verticesPerPolygon : Int, polygonsSize : Int, verticesPerFace : Int, trianglesSize : Int)
   {
      guard let coordNode = coordNode else { return }
      
      // Set size to a multiple of verticesPerPolygon.

      let polygonsSize  = polygonsSize - polygonsSize % verticesPerPolygon
      let trianglesSize = trianglesSize - trianglesSize % verticesPerFace
      
      isSolid            = solid
      isCounterClockwise = ccw
      hasColor           = colorNode != nil
      hasTexCoord        = texCoordNode != nil
      
      var fogDepth  = Float (0)
      var color     = Color4f .one
      var texCoords = [Vector4f] ()
      let normals   = normalNode == nil ? makeNormals (verticesPerPolygon, polygonsSize) : Normals ()
      var normal    = Vector3f .zero
      var face      = 0
      
      for i in 0 ..< trianglesSize
      {
         face = i / verticesPerFace

         let index = getPolygonIndex (at: getTriangleIndex (at: i))

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

         if let texCoordNode = texCoordNode
         {
            texCoords .removeAll (keepingCapacity: true)
            
            texCoordNode .get1Point (at: index, array: &texCoords)
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
            normal = normals [getTriangleIndex (at: i)]
         }

         let point = coordNode .get1Point (at: index)
         
         addPrimitive (fogDepth: fogDepth,
                       color: color,
                       texCoords: texCoords,
                       normal: normal,
                       point: point)
      }
   }
   
   internal func makeNormals (_ verticesPerPolygon : Int, _ polygonsSize : Int) -> Normals
   {
      let faceNormals = makeFaceNormals (verticesPerPolygon, polygonsSize)
   
      guard normalPerVertex else { return faceNormals }
      
      var normalIndex = NormalIndex ()

      for i in 0 ..< polygonsSize
      {
         normalIndex [getPolygonIndex (at: i), default: [ ]] .append (i)
      }

      return generateNormals (normalIndex: normalIndex, faceNormals: faceNormals, creaseAngle: Float .pi)
   }

   internal final func makeFaceNormals (_ verticesPerPolygon : Int, _ polygonsSize : Int) -> Normals
   {
      var normals = Normals ()

      for i in stride (from: 0, to: polygonsSize, by: verticesPerPolygon)
      {
         let normal = makePolygonNormal (i, verticesPerPolygon)

         for _ in 0 ..< verticesPerPolygon
         {
            normals .append (normal)
         }
      }
      
      if !ccw
      {
         for i in 0 ..< normals .count
         {
            normals [i] = -normals [i]
         }
      }

      return normals
   }
   
   private final func makePolygonNormal (_ index : Int, _ verticesPerPolygon : Int) -> Vector3f
   {
      guard let coordNode = coordNode else { return .zero }
      
      // Determine polygon normal.
      // We use Newell's method https://www.opengl.org/wiki/Calculating_a_Surface_Normal here:

      var normal  = Vector3f .zero
      var current = Vector3f .zero
      var next    = coordNode .get1Point (at: getPolygonIndex (at: index))

      for i in 0 ..< verticesPerPolygon
      {
         swap (&current, &next)

         next = coordNode .get1Point (at: getPolygonIndex (at: index + (i + 1) % verticesPerPolygon))

         normal .x += (current .y - next .y) * (current .z + next .z)
         normal .y += (current .z - next .z) * (current .x + next .x)
         normal .z += (current .x - next .x) * (current .y + next .y)
      }

      return normalize (normal)
   }
}
