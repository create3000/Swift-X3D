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
   }
   
   internal final func setup ()
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
   }
   
   /// Override to initialize node.
   internal func initialize () { }

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
   
   public final func getPreDefinedFields () -> ArraySlice <X3DField>
   {
      fieldDefinitions [..<(fieldDefinitions .count - numUserDefinedFields)]
   }
   
   public final func getUserDefinedFields () -> ArraySlice <X3DField>
   {
      fieldDefinitions [(fieldDefinitions .count - numUserDefinedFields)...]
   }
 
   internal final func addUserDefinedField (_ accessType : X3DAccessType, _ name : String, _ field : X3DField)
   {
      addField (accessType, name, field)
      
      numUserDefinedFields += 1
   }
   
   public final func getField (name : String) throws -> X3DField
   {
      let name = aliases [name] ?? name
      
      if let field = fieldIndex [name]
      {
         return field
      }
      
      if let field = fieldIndex ["set_" + name]
      {
         if field .getAccessType () == .inputOutput
         {
            return field
         }
      }
      
      if let field = fieldIndex [name + "_changed"]
      {
         if field .getAccessType () == .inputOutput
         {
            return field
         }
      }

      throw X3DError .INVALID_X3D (t("Unknown field '%@' in class '%@'.", name, getTypeName ()))
   }
   
   // Private
   
   internal final var isPrivate : Bool = false
   {
      didSet { }
   }
   
   // Event handling
   
   internal final override func addEvent (for object : X3DChildObject)
   {
      guard let field = object as? X3DField else { return }

      guard !field .isTainted else { return }

//      debugPrint (#file, #function, typeName, field .identifier)

      addEventObject (for: field, event: X3DEvent (field))
   }

   internal final override func addEventObject (for field : X3DField, event : X3DEvent)
   {
      // Register field for processEvent.

      field .isTainted = true

      browser? .addTaintedField (field: field, event: event)

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
   
   // Convert to string
   
   internal override func toStream (_ stream : X3DOutputStream)
   {
      stream += getTypeName () + " { }"
   }

   // Destruction
   
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

      if !getName () .isEmpty
      {
         executionContext? .removeNamedNode (name: getName ())
      }
   }
}
