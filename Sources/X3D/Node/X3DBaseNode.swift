//
//  X3DBaseNode.swift
//  X3D
//
//  Created by Holger Seelig on 07.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DBaseNode :
   X3DChildObject
{
   // Common properties

   public private(set) final weak var browser : X3DBrowser?
   public var scene : X3DScene? { executionContext? .scene }
   public internal(set) weak var executionContext : X3DExecutionContext?
   internal final var types : [X3DNodeType] = [ ]
   
   public final func getType () -> [X3DNodeType] { types }

   // Construction
   
   internal init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init ()
      
      self .browser          = browser
      self .executionContext = executionContext
      
      addChildObjects ($name_changed,
                       $fields_changed)
   }
   
   public final func setup ()
   {
      // Contruction
      
      initialize ()
      
      // Event handling
      
      for child in children
      {
         child .isTainted = false
      }

      for field in fieldDefinitions
      {
         field .isTainted = false
      }
      
      isInitialized = true
   }
   
   /// Override to initialize node.
   internal func initialize () { }
   
   public private(set) final var isInitialized = false
   
   // Name handling
   
   @SFTime public final var name_changed = 0

   internal final override func setName (_ value : String)
   {
      super .setName (value)
      
      if Thread .isMainThread
      {
         name_changed = SFTime .now
      }
   }

   // Children handling
   
   private final var children = [X3DField] ()
   
   internal final func addChildObjects (_ children : X3DField...)
   {
      for child in children
      {
         child .isTainted = true
         child .addParent (self)
      }
      
      self .children .append (contentsOf: children)
   }

   // Field handling
   
   public var canUserDefinedFields    : Bool { false }
   internal var extendedEventHandling : Bool { true }
   private final var fieldDefinitions : [X3DField] = [ ]
   private final var fieldIndex       : [String : X3DField] = [:]
   
   @SFTime public final var fields_changed = 0

   public final func getFieldDefinitions () -> [X3DField] { fieldDefinitions }
   
   ///
   internal final func addField (_ accessType : X3DAccessType, _ name : String, _ field : X3DField)
   {
      field .isTainted = true
      field .addParent (self)

      field .setName (name)
      field .setAccessType (accessType)
      
      // Add to field set
      
      fieldIndex [name] = field
      fieldDefinitions .append (field)
      
      if accessType == .inputOutput
      {
         fieldIndex ["set_" + name]     = field
         fieldIndex [name + "_changed"] = field
      }
      
      if Thread .isMainThread
      {
         fields_changed = SFTime .now
      }
   }
   
   private final var aliases : [String : String] = [:]
   
   internal final func addFieldAlias (alias : String, name : String)
   {
      aliases [alias] = name
      
      if fieldIndex [name]! .getAccessType () == .inputOutput
      {
         aliases ["set_" + alias]    = name
         aliases [alias + "changed"] = name
      }
   }
   
   private final var numUserDefinedFields : Int = 0
   
   public final func getPreDefinedFields () -> [X3DField]
   {
      [X3DField] (fieldDefinitions [..<(fieldDefinitions .count - numUserDefinedFields)])
   }
   
   public final func getUserDefinedFields () -> [X3DField]
   {
      [X3DField] (fieldDefinitions [(fieldDefinitions .count - numUserDefinedFields)...])
   }
 
   internal final func addUserDefinedField (_ accessType : X3DAccessType, _ name : String, _ field : X3DField)
   {
      addField (accessType, name, field)
      
      numUserDefinedFields += 1
   }
   
   public final func removeUserDefinedField (_ name : String)
   {
      guard let index = fieldDefinitions .firstIndex (where: { $0 .getName () == name }) else { return }
      
      guard index >= fieldDefinitions .count - numUserDefinedFields else { return }
      
      let field = fieldDefinitions [index]
      
      field .removeParent (self)
      
      fieldIndex .removeValue (forKey: field .getName ())
      fieldDefinitions .remove (at: index)
      
      numUserDefinedFields -= 1
      
      if Thread .isMainThread
      {
         fields_changed = SFTime .now
      }
   }

   public final func getField <Type : X3DField> (of type : Type .Type, name : String) throws -> Type
   {
      guard let field = try getField (name: name) as? Type else
      {
         throw X3DError .INVALID_FIELD ("Field has invalid type.")
      }
      
      return field
   }

   public final func getField (name : String) throws -> X3DField
   {
      let name = aliases [name] ?? name
      
      if let field = fieldIndex [name]
      {
         return field
      }

      throw X3DError .INVALID_NAME (t("Unknown field '%@' in class '%@'.", name, getTypeName ()))
   }
   
   // Private
   
   internal final var isPrivate : Bool = false
   
   // Event handling
   
   internal final override func addEvent (for object : X3DChildObject)
   {
      guard let field = object as? X3DField else { return }
      
      guard !field .isTainted else { return }

      field .isTainted = true

      addEventObject (for: field, event: X3DEvent (field))
   }

   internal final override func addEventObject (for field : X3DField, event : X3DEvent)
   {
      // Register field for processEvent.
      
//      if getName () == "Puck"
//      {
//         debugPrint (#file, #function, getName (), getTypeName (), field .getName (), field .isTainted, browser! .currentTime)
//      }

      browser? .addTaintedField (field: field, event: event)
      browser? .setNeedsDisplay ()

      guard field .isInput || (extendedEventHandling && !field .isOutput) else { return }

      addNodeEvent ()
   }
   
   internal final func addNodeEvent ()
   {
      guard !isTainted else { return }

      isSet     = true
      isTainted = true

      // Register node for processEvents.
      
      browser? .addTaintedNode (node: self)
      browser? .setNeedsDisplay ()
   }
   
   internal final func processEvents ()
   {
      isTainted = false

      processInterests ()
   }

   // Destruction
   
   public final let deleted = Output ()
   
   deinit
   {
      //debugPrint (#file, #function, Swift .type (of: self))
      
      for child in children
      {
         child .removeParent (self)
      }
      
      for field in fieldDefinitions
      {
         field .removeParent (self)
      }
      
      deleted .processInterests ()
   }
}
