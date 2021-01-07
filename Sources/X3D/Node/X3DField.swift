//
//  X3DField.swift
//  X3D
//
//  Created by Holger Seelig on 08.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DField :
   X3DFieldDefinition
{
   // Construction
   
   /// Creates a new fresh copy of this field.
   public func copy () -> X3DField { self }

   // Value handling

   /// Compares this field with `other`.
   public func equals (to field : X3DField) -> Bool { false }

   /// Assigns a value to this field without generating an event.
   internal func set (value field : X3DField) { }
   
   /// Deep copies value from field and set this value without generating an event.
   internal func set (with protoInstance : X3DPrototypeInstance, value field : X3DField)
   {
      set (value: field)
   }
   
   // Reference handling
   
   /// Set of `IS` relation ships.
   public private(set) final var references = NSHashTable <X3DField> (options: .weakMemory)
   
   /// Test if this field is possible for a `IS` relation ship.
   public final func isReference (for accessType : X3DAccessType) -> Bool
   {
      return accessType == self .getAccessType () || accessType == .inputOutput
   }
   
   public final func addReference (to reference : X3DField)
   {
      references .add (reference)
      
      // Add IS relationship.

      switch getAccessType () .rawValue & reference .getAccessType () .rawValue
      {
         case X3DAccessType .initializeOnly .rawValue:
            reference .addFieldInterest (to: self)
            set (value: reference)
            
         case X3DAccessType .inputOnly .rawValue:
            reference .addFieldInterest (to: self)
            
         case X3DAccessType .outputOnly .rawValue:
            addFieldInterest (to: reference)
            
         case X3DAccessType .inputOutput .rawValue:
            reference .addFieldInterest (to: self)
            addFieldInterest (to: reference)
            set (value: reference)
            
         default: break
      }
   }
   
   public final func removeReference (to reference : X3DField)
   {
      references .remove (reference)
      
      // Remove IS relationship.

      switch getAccessType () .rawValue & reference .getAccessType () .rawValue
      {
         case X3DAccessType .initializeOnly .rawValue:
            reference .removeFieldInterest (to: self)
            
         case X3DAccessType .inputOnly .rawValue:
            reference .removeFieldInterest (to: self)
            
         case X3DAccessType .outputOnly .rawValue:
            removeFieldInterest (to: reference)
            
         case X3DAccessType .inputOutput .rawValue:
            reference .removeFieldInterest (to: self)
            removeFieldInterest (to: reference)
            
         default: break
      }
   }

   // Route handling

   public private(set) final var inputFieldInterests  = NSHashTable <X3DField> (options: .weakMemory)
   public private(set) final var outputFieldInterests = NSHashTable <X3DField> (options: .weakMemory)
   
   /// Adds a interest for field.
   internal final func addFieldInterest (to field : X3DField)
   {
      assert (field .getType () == getType ())
      
      outputFieldInterests .add (field)
      field .addInputFieldInterest (to: self)
   }

   /// Removes a interest for field.
   internal final func removeFieldInterest (to field : X3DField)
   {
      assert (field .getType () == getType ())
      
      outputFieldInterests .remove (field)
      field .removeInputFieldInterest (to: self)
   }
   
   /// Adds a input interest for field.
   private final func addInputFieldInterest (to field : X3DField)
   {
      inputFieldInterests .add (field)
   }

   /// Removes a input interest for field.
   private final func removeInputFieldInterest (to field : X3DField)
   {
      inputFieldInterests .remove (field)
   }

   // Event handling
   
   /// Process and forward event.
   internal final func processEvent (_ event : X3DEvent)
   {
      guard event .sources .insert (self) .inserted else { return }
      
      // Set value.

      if event .field !== self
      {
         isTainted = true
         
         set (value: event .field)
      }
      
      isTainted = false

      // Process interests.

      processInterests ()
      
      // Process routes.

      var first = true

      for field in outputFieldInterests .allObjects
      {
         if (first)
         {
            first = false

            field .addEventObject (for: field, event: event)
         }
         else
         {
            field .addEventObject (for: field, event: event .copy ())
         }
      }
   }
   
   // Input/Output
   
   public final func toDisplayString (_ executionContext : X3DExecutionContext) -> String
   {
      let stream = X3DOutputStream ()
      
      stream .executionContexts .append (executionContext)
      
      toDisplayStream (stream)
      
      return stream .string
   }
   
   internal func toDisplayStream (_ stream : X3DOutputStream)
   {
      toStream (stream)
   }

   public func fromDisplayString (_ string : String, scene : X3DScene) -> Bool
   {
      return fromDisplayStream (VRMLParser (scene: scene, x3dSyntax: string))
   }
   
   internal func fromDisplayStream (_ parser : VRMLParser) -> Bool { return false }
   
   // Destruction
   
   deinit
   {
      // Maybe this is not needed because we have a weak map.
      
      for field in inputFieldInterests .allObjects
      {
         field .removeFieldInterest (to: self)
      }

      for field in outputFieldInterests .allObjects
      {
         field .removeInputFieldInterest (to: self)
      }
   }
}
