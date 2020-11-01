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
   
   /// Assigns a value to this field without generating an event.
   internal func set (value field : X3DField) { }
   
   /// Deep copies value from field and set this value without generating an event.
   internal func set (with protoInstance : X3DPrototypeInstance, value field : X3DField) { set (value: field) }
   
   // Reference handling
   
   /// Set of `IS` relation ships.
   public private(set) final var references = NSHashTable <X3DField> (options: .weakMemory)
   
   /// Test if this field is possible for a `IS` relation ship.
   public final func isReference (for accessType : X3DAccessType) -> Bool
   {
      return accessType == self .accessType || accessType == .inputOutput
   }
   
   public final func addReference (to reference : X3DField)
   {
      references .add (reference)
      
      // Add IS relationship.

      switch accessType .rawValue & reference .accessType .rawValue
      {
         case X3DAccessType .initializeOnly .rawValue:
            reference .addFieldInterest (to: self)
            set (value: reference)
            
         case X3DAccessType .inputOnly .rawValue:
            reference.addFieldInterest (to: self)
            
         case X3DAccessType .outputOnly .rawValue:
            addFieldInterest (to: reference)
            
         case X3DAccessType .inputOutput .rawValue:
            reference .addFieldInterest (to: self)
            addFieldInterest (to: reference)
            set (value: reference)
            
         default: break
      }

//      updateReference (reference)
   }
   
   public final func removeReference (to reference : X3DField)
   {
      references .remove (reference)
      
      // Remove IS relationship.

      switch accessType .rawValue & reference .accessType .rawValue
      {
         case X3DAccessType .initializeOnly .rawValue:
            reference .removeFieldInterest (to: self)
            
         case X3DAccessType .inputOnly .rawValue:
            reference.removeFieldInterest (to: self)
            
         case X3DAccessType .outputOnly .rawValue:
            removeFieldInterest (to: reference)
            
         case X3DAccessType .inputOutput .rawValue:
            reference .removeFieldInterest (to: self)
            removeFieldInterest (to: reference)
            
         default: break
      }
   }
   
//   public final func updateReferences ()
//   {
//      for reference in references
//      {
//         updateReference (reference .object!)
//      }
//   }
//
//   private final func updateReference (_ reference : X3DField)
//   {
//      switch accessType .rawValue & reference .accessType .rawValue
//      {
//         case X3DAccessType .initializeOnly .rawValue:
//            set (value: reference)
//
//         case X3DAccessType .inputOnly .rawValue:
//            break
//
//         case X3DAccessType .outputOnly .rawValue:
//            break
//
//         case X3DAccessType .inputOutput .rawValue:
//            set (value: reference)
//
//         default: break
//      }
//   }

   // Route handling

   private final var inputFieldInterests  = NSHashTable <X3DField> (options: .weakMemory)
   private final var outputFieldInterests = NSHashTable <X3DField> (options: .weakMemory)
   
   /// Adds a interest for field.
   internal final func addFieldInterest (to field : X3DField)
   {
      outputFieldInterests .add (field)
      field .addInputFieldInterest (to: self)
   }

   /// Removes a interest for field.
   internal final func removeFieldInterest (to field : X3DField)
   {
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
      guard event .sources .insert (self) .0 else { return }

      isTainted = false
      
      // Set value.

      if event .field !== self
      {
         set (value: event .field)
      }
      
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
