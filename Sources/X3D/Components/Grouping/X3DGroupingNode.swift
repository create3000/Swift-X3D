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

   @SFVec3f public final var bboxSize       : Vector3f = -.one
   @SFVec3f public final var bboxCenter     : Vector3f = .zero
   @MFNode  public final var addChildren    : [X3DNode?]
   @MFNode  public final var removeChildren : [X3DNode?]
   @MFNode  public final var children       : [X3DNode?]
   
   // Properties
   
   @MFBool public final var visible  : [Bool]
   @SFBool public final var isHidden : Bool = false

   private  final var fogNodes                  = [LocalFog] ()
   private  final var lightNodes                = [X3DLightNode] ()
   private  final var pointingDeviceSensorNodes = [X3DPointingDeviceSensorNode] ()
   internal final var transformSensorNodes      = [TransformSensor] ()
   private  final var maybeCameraObjects        = [X3DChildNode] ()
   private  final var cameraObjects             = [X3DChildNode] ()
   private  final var childNodes                = [X3DChildNode] ()

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)
      
      initBoundedObject (bboxSize: $bboxSize, bboxCenter: $bboxCenter)
      
      types .append (.X3DGroupingNode)
      
      addChildObjects ($visible,
                       $isHidden)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $addChildren    .addInterest ("set_addChildren",    { $0 .set_addChildren () },    self)
      $removeChildren .addInterest ("set_removeChildren", { $0 .set_removeChildren () }, self)
      $children       .addInterest ("set_children",       { $0 .set_children () },       self)
      $isHidden       .addInterest ("set_children",       { $0 .set_children () },       self)
      
      set_children ()
   }
   
   // Bounded object
   
   public var bbox : Box3f { .empty }

   // Event handlers
   
   private final func set_addChildren ()
   {
      if !$children .isTainted
      {
         $children .removeInterest ("set_children", self)
         $children .addInterest    ("set_children", { $0 .connectChildren () }, self)
      }
      
      let difference = addChildren .difference (from: children)
 
      for change in difference
      {
         switch change
         {
            case let .insert (_, newElement, _):
               children .append (newElement)
            default:
               break
         }
      }

      add (at: children .count, contentsOf: addChildren)
   }
   
   private final func set_removeChildren ()
   {
      
   }
   
   private final func set_children ()
   {
      clear ()
      add (at: 0, contentsOf: children)
   }
   
   private final func connectChildren ()
   {
      $children .removeInterest ("set_children", self)
      $children .addInterest    ("set_children", { $0 .set_children () }, self)
   }

   // Methods

   private final func clear ()
   {
      childNodes .forEach { $0 .$isCameraObject .removeInterest ("set_cameraObjects", self) }
      
      fogNodes                  .removeAll (keepingCapacity: true)
      lightNodes                .removeAll (keepingCapacity: true)
      pointingDeviceSensorNodes .removeAll (keepingCapacity: true)
      transformSensorNodes      .removeAll (keepingCapacity: true)
      maybeCameraObjects        .removeAll (keepingCapacity: true)
      childNodes                .removeAll (keepingCapacity: true)
   }

   private final func add (at first : Int, contentsOf children : [X3DNode?])
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
                        fogNodes .append (innerNode as! LocalFog)
                     }
                     case .X3DBindableNode: do
                     {
                        maybeCameraObjects .append (innerNode as! X3DChildNode)
                     }
                     case .X3DChildNode: do
                     {
                        let childNode = innerNode as! X3DChildNode
                        
                        childNode .$isCameraObject .addInterest ("set_cameraObjects", { $0 .set_cameraObjects () }, self)
                        
                        maybeCameraObjects .append (childNode)
                        childNodes .append (childNode)
                     }
                     case .X3DLightNode: do
                     {
                        lightNodes .append (innerNode as! X3DLightNode)
                     }
                     case .X3DPointingDeviceSensorNode: do
                     {
                        pointingDeviceSensorNodes .append (innerNode as! X3DPointingDeviceSensorNode)
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
         if maybeCameraObject .isCameraObject
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
   
   internal override func traverse (_ type : TraverseType, _ renderer : Renderer)
   {
      switch type
      {
         case .Pointer: do
         {
            let browser = renderer .browser
            
            if !pointingDeviceSensorNodes .isEmpty
            {
               browser .sensors .append (Set <PointingDeviceSensorContainer> ())
               
               pointingDeviceSensorNodes .forEach
               {
                  $0 .push (renderer: renderer,
                            sensors: &browser .sensors [browser .sensors .endIndex - 1])
               }
            }
            
            childNodes .forEach { $0 .traverse (type, renderer) }
            
            if !pointingDeviceSensorNodes .isEmpty
            {
               browser .sensors .removeLast ()
            }
         }
         case .Camera: do
         {
            cameraObjects .forEach { $0 .traverse (type, renderer) }
         }
         case .Picking: do
         {
         }
         case .Collision: do
         {
            childNodes .forEach { $0 .traverse (type, renderer) }
         }
         case .Depth: do
         {
         }
         case .Render: do
         {
            fogNodes   .forEach { $0 .push (renderer) }
            lightNodes .forEach { $0 .push (renderer, self) }
            
            childNodes .forEach { $0 .traverse (type, renderer) }
            
            lightNodes .reversed () .forEach { $0 .pop (renderer) }
            fogNodes   .reversed () .forEach { $0 .pop (renderer) }
         }
      }
   }
}
