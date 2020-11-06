//
//  ViewpointGroup.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class ViewpointGroup :
   X3DChildNode,
   X3DNodeInterface
{
   // Common properties
   
   public final override class var typeName       : String { "ViewpointGroup" }
   public final override class var component      : String { "Navigation" }
   public final override class var componentLevel : Int32 { 2 }
   public final override class var containerField : String { "children" }

   // Fields

   @SFString public final var description       : String = ""
   @SFBool   public final var displayed         : Bool = true
   @SFBool   public final var retainUserOffsets : Bool = false
   @SFVec3f  public final var size              : Vector3f = .zero
   @SFVec3f  public final var center            : Vector3f = .zero
   @MFNode   public final var children          : MFNode <X3DNode> .Value
   
   // Properties
   
   @SFNode private final var proximitySensorNode : ProximitySensor!
   @MFNode private final var cameraObjects       : MFNode <X3DChildNode> .Value
   @MFNode private final var viewpointGroupNodes : MFNode <ViewpointGroup> .Value

   // Construction
   
   public init (with executionContext : X3DExecutionContext)
   {
      self .proximitySensorNode = ProximitySensor (with: executionContext)
      
      super .init (executionContext .browser!, executionContext)

      types .append (.ViewpointGroup)

      addField (.inputOutput, "metadata",          $metadata)
      addField (.inputOutput, "description",       $description)
      addField (.inputOutput, "displayed",         $displayed)
      addField (.inputOutput, "retainUserOffsets", $retainUserOffsets)
      addField (.inputOutput, "size",              $size)
      addField (.inputOutput, "center",            $center)
      addField (.inputOutput, "children",          $children)
      
      addChildObjects ($proximitySensorNode,
                       $cameraObjects,
                       $viewpointGroupNodes)

      $size   .unit = .length
      $center .unit = .length
   }

   internal final override func create (with executionContext : X3DExecutionContext) -> ViewpointGroup
   {
      return ViewpointGroup (with: executionContext)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      $size   .addFieldInterest (to: proximitySensorNode .$size)
      $center .addFieldInterest (to: proximitySensorNode .$center)

      proximitySensorNode .size   = size
      proximitySensorNode .center = center
      
      $displayed .addInterest (ViewpointGroup .set_displayed, self)
      $size      .addInterest (ViewpointGroup .set_displayed, self)
      $children  .addInterest (ViewpointGroup .set_children,  self)
      
      set_displayed ()
      set_children ()
      
      proximitySensorNode .setup ()
   }
   
   private final func set_displayed ()
   {
      if displayed && size != .zero
      {
         proximitySensorNode .enabled = true
         
         proximitySensorNode .$isCameraObject   .addFieldInterest (to: $isCameraObject)
         proximitySensorNode .$isPickableObject .addFieldInterest (to: $isPickableObject)

         setCameraObject (proximitySensorNode .isCameraObject)
         setPickableObject (proximitySensorNode .isPickableObject)
      }
      else
      {
         proximitySensorNode .enabled = false
         
         proximitySensorNode .$isCameraObject   .removeFieldInterest (to: $isCameraObject)
         proximitySensorNode .$isPickableObject .removeFieldInterest (to: $isPickableObject)

         setCameraObject (displayed)
         setPickableObject (false)
      }
   }
   
   private final func set_children ()
   {
      cameraObjects       .removeAll (keepingCapacity: true)
      viewpointGroupNodes .removeAll (keepingCapacity: true)
      
      for child in children
      {
         guard let innerNode = child? .innerNode else { continue }
         
         for type in innerNode .types .reversed ()
         {
            switch type
            {
               case .ViewpointGroup: do
               {
                  cameraObjects       .append (innerNode as? ViewpointGroup)
                  viewpointGroupNodes .append (innerNode as? ViewpointGroup)
               }
               case .X3DViewpointNode: do
               {
                  cameraObjects .append (innerNode as? X3DViewpointNode)
               }
               default:
                  continue
            }
            
            break
         }
      }
   }
   
   internal final override func traverse (_ type: X3DTraverseType, _ renderer: X3DRenderer)
   {
      switch type
      {
         case .Camera: do
         {
            proximitySensorNode .traverse (type, renderer)
      
            if proximitySensorNode .isActive || !proximitySensorNode .enabled
            {
               for cameraObject in cameraObjects
               {
                  cameraObject! .traverse (type, renderer)
               }
            }
         }
         case .Render: do
         {
            proximitySensorNode .traverse (type, renderer)
            
            if proximitySensorNode .isActive || !proximitySensorNode .enabled
            {
               for viewpointGroupNode in viewpointGroupNodes
               {
                  viewpointGroupNode! .traverse (type, renderer)
               }
            }
         }
         default:
            break
      }
   }
}
