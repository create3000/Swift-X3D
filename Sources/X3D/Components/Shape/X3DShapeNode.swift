//
//  X3DShapeNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public class X3DShapeNode :
   X3DChildNode,
   X3DBoundedObject
{
   // Fields

   @SFVec3f public final var bboxSize   : Vector3f = Vector3f (-1, -1, -1)
   @SFVec3f public final var bboxCenter : Vector3f = Vector3f .zero
   @SFNode  public final var appearance : X3DNode?
   @SFNode  public final var geometry   : X3DNode?
   
   // Properties
   
   @SFBool internal final var isTransparent  : Bool = false
   @SFNode internal final var appearanceNode : X3DAppearanceNode?
   @SFNode internal final var geometryNode   : X3DGeometryNode?

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)

      types .append (.X3DShapeNode)
      
      addChildObjects ($isTransparent,
                       $appearanceNode,
                       $geometryNode)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $appearance .addInterest (X3DShapeNode .set_appearance, self)
      $geometry   .addInterest (X3DShapeNode .set_geometry,   self)
      
      set_appearance ()
      set_geometry ()
   }
   
   // Bounded object
   
   public var bbox : Box3f { Box3f () }

   // Member accsess
   
   internal final func setTransparent (_ value : Bool)
   {
      guard value != isTransparent else { return }
      
      isTransparent = value
   }

   // Event handlers
   
   private final func set_appearance ()
   {
      appearanceNode? .$isTransparent .removeInterest (X3DShapeNode .set_transparent, self)
      
      appearanceNode = appearance? .innerNode as? X3DAppearanceNode ?? browser! .defaultAppearanceNode
      
      appearanceNode? .$isTransparent .addInterest (X3DShapeNode .set_transparent, self)
      
      set_transparent ()
   }
   
   private final func set_geometry ()
   {
      geometryNode? .$isTransparent .removeInterest (X3DShapeNode .set_transparent, self)
      
      geometryNode = geometry? .innerNode as? X3DGeometryNode
      
      geometryNode? .$isTransparent .addInterest (X3DShapeNode .set_transparent, self)
      
      set_transparent ()
   }
   
   private final func set_transparent ()
   {
      setTransparent (geometryNode? .isTransparent ?? false || appearanceNode! .isTransparent)
   }
 
   // Rendering
   
   /// Renders geometry to surface with appearance applied.
   internal func render (_ context : X3DRenderContext, _ renderEncoder : MTLRenderCommandEncoder) { }
   
   // Destruction
   
   deinit
   {
      debugPrint (typeName, #function, hashValue)
   }
}
