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
   
   internal final override class var typeName       : String { "ViewpointGroup" }
   internal final override class var component      : String { "Navigation" }
   internal final override class var componentLevel : Int32 { 2 }
   internal final override class var containerField : String { "children" }
   internal final override class var implemented    : Implemented { (sunrise: false, x_ite: true) }

   // Fields

   @SFString public final var description       : String = ""
   @SFBool   public final var displayed         : Bool = true
   @SFBool   public final var retainUserOffsets : Bool = false
   @SFVec3f  public final var size              : Vector3f = .zero
   @SFVec3f  public final var center            : Vector3f = .zero
   @MFNode   public final var children          : [X3DNode?]
   
   // Properties
   
   private final var proximitySensorNode : ProximitySensor
   private final var cameraObjects       : [X3DChildNode] = [ ]
   private final var viewpointGroupNodes : [ViewpointGroup] = [ ]

   // Construction
   
   required internal init (with executionContext : X3DExecutionContext)
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
      
      $displayed .addInterest ("set_displayed", { $0 .set_displayed () }, self)
      $size      .addInterest ("set_displayed", { $0 .set_displayed () }, self)
      $children  .addInterest ("set_children",  { $0 .set_children () },  self)
      
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
                  cameraObjects       .append (innerNode as! ViewpointGroup)
                  viewpointGroupNodes .append (innerNode as! ViewpointGroup)
               }
               case .X3DViewpointNode: do
               {
                  cameraObjects .append (innerNode as! X3DViewpointNode)
               }
               default:
                  continue
            }
            
            break
         }
      }
   }
   
   internal final override func traverse (_ type: TraverseType, _ renderer: Renderer)
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
                  cameraObject .traverse (type, renderer)
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
                  viewpointGroupNode .traverse (type, renderer)
               }
            }
         }
         default:
            break
      }
   }
}
