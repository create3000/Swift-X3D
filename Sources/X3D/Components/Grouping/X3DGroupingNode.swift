//
//  X3DGroupingNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Metal

public class X3DGroupingNode :
   X3DChildNode,
   X3DBoundedObject
{
   // Fields

   @SFVec3f public final var bboxSize       : Vector3f = Vector3f (-1, -1, -1)
   @SFVec3f public final var bboxCenter     : Vector3f = .zero
   @MFNode  public final var addChildren    : MFNode <X3DNode> .Value
   @MFNode  public final var removeChildren : MFNode <X3DNode> .Value
   @MFNode  public final var children       : MFNode <X3DNode> .Value
   
   // Properties
   
   @MFBool public final var visible  : MFBool .Value
   @SFBool public final var isHidden : Bool = false

   @MFNode private  final var fogNodes             : MFNode <LocalFog> .Value
   @MFNode private  final var lightNodes           : MFNode <X3DLightNode> .Value
   @MFNode internal final var transformSensorNodes : MFNode <TransformSensor> .Value
   @MFNode private  final var maybeCameraObjects   : MFNode <X3DChildNode> .Value
   @MFNode private  final var cameraObjects        : MFNode <X3DChildNode> .Value
   @MFNode private  final var childNodes           : MFNode <X3DChildNode> .Value

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)
      
      types .append (.X3DGroupingNode)
      
      addChildObjects ($visible,
                       $isHidden,
                       $fogNodes,
                       $lightNodes,
                       $transformSensorNodes,
                       $maybeCameraObjects,
                       $cameraObjects,
                       $childNodes)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $addChildren    .addInterest (X3DGroupingNode .set_addChildren,    self)
      $removeChildren .addInterest (X3DGroupingNode .set_removeChildren, self)
      $children       .addInterest (X3DGroupingNode .set_children,       self)
      $isHidden       .addInterest (X3DGroupingNode .set_children,       self)
      
      set_children ()
   }
   
   // Bounded object
   
   public var bbox : Box3f { Box3f () }

   // Event handlers
   
   private final func set_addChildren ()
   {
      
   }
   
   private final func set_removeChildren ()
   {
      
   }
   
   private final func set_children ()
   {
      clear ()
      add (at: 0, contentsOf: children)
   }

   // Methods

   private final func clear ()
   {
      for childNode in childNodes
      {
         childNode! .$isCameraObject .removeInterest (X3DGroupingNode .set_cameraObjects, self)
      }
      
      fogNodes           .removeAll (keepingCapacity: true)
      lightNodes         .removeAll (keepingCapacity: true)
      maybeCameraObjects .removeAll (keepingCapacity: true)
      childNodes         .removeAll (keepingCapacity: true)
   }

   private final func add (at first : Int, contentsOf children : MFNode <X3DNode> .Value)
   {
      guard !isHidden else { return }
      
      var i = first
      
      for child in children
      {
         if child != nil && (i >= visible .count || visible [i])
         {
            if let innerNode = child? .innerNode
            {
               for type in innerNode .types .reversed ()
               {
                  switch type
                  {
                     case .LocalFog: do
                     {
                        fogNodes .append (innerNode as? LocalFog)
                     }
                     case .X3DBindableNode: do
                     {
                        maybeCameraObjects .append (innerNode as? X3DChildNode)
                     }
                     case .X3DChildNode: do
                     {
                        let childNode = innerNode as! X3DChildNode
                        
                        childNode .$isCameraObject .addInterest (X3DGroupingNode .set_cameraObjects, self)
                        
                        maybeCameraObjects .append (childNode)
                        childNodes .append (childNode)
                     }
                     case .X3DLightNode: do
                     {
                        lightNodes .append (innerNode as? X3DLightNode)
                     }
                     case
                        .BooleanFilter,
                        .BooleanToggle,
                        .CollisionSensor,
                        .NurbsOrientationInterpolator,
                        .NurbsPositionInterpolator,
                        .NurbsSurfaceInterpolator,
                        .RigidBodyCollection,
                        .TimeSensor,
                        .X3DFollowerNode,
                        .X3DInfoNode,
                        .X3DInterpolatorNode,
                        .X3DKeyDeviceSensorNode,
                        .X3DLayoutNode,
                        .X3DScriptNode,
                        .X3DSequencerNode,
                        .X3DTriggerNode:
                           break
                     default:
                        continue
                  }

                  break
               }
            }
         }
         
         i += 1
      }
      
      set_cameraObjects ()
   }
   
   // Event handlers
      
   internal func set_cameraObjects ()
   {
      cameraObjects .removeAll ()

      for maybeCameraObject in maybeCameraObjects
      {
         if maybeCameraObject! .isCameraObject
         {
            cameraObjects .append (maybeCameraObject)
         }
      }

      setCameraObject (!cameraObjects .isEmpty)
   }
   
   internal func set_pickableObjects ()
   {
      
   }

   // Rendering
   
   internal override func traverse (_ type : X3DTraverseType, _ renderer : X3DRenderer)
   {
      switch type
      {
         case .Pointer: do
         {
         }
         case .Camera: do
         {
            for cameraObject in cameraObjects
            {
               cameraObject! .traverse (type, renderer)
            }
         }
         case .Picking: do
         {
         }
         case .Collision: do
         {
         }
         case .Depth: do
         {
         }
         case .Render: do
         {
            for fogNode in fogNodes
            {
               fogNode! .push (renderer)
            }
            
            for lightNode in lightNodes
            {
               lightNode! .push (renderer, self)
            }
            
            for childNode in childNodes
            {
               childNode! .traverse (type, renderer)
            }
            
            for lightNode in lightNodes .reversed ()
            {
               lightNode! .pop (renderer)
            }
            
            for fogNode in fogNodes .reversed ()
            {
               fogNode! .pop (renderer)
            }
         }
      }
   }
}
