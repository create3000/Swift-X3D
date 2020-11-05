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
   // Common properies

   public private(set) final weak var browser : X3DBrowser?
   public var scene : X3DScene? { executionContext? .scene }
   public internal(set) weak var executionContext : X3DExecutionContext?
   public internal(set) final var types : [X3DNodeType] = [ ]

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

      for field in fields
      {
         field .isTainted = false
      }
   }
   
   /// Override to initialize node.
   internal func initialize () { }
   
   internal func copy (with protoInstance : X3DPrototypeInstance) -> X3DBaseNode { self }

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
   
   public var canUserDefinedFields : Bool { false }
   public var extendedEventHandling : Bool { true }
   public private(set) final var fields : [X3DField] = [ ]
   private final var fieldIndex : [String : X3DField] = [:]

   ///
   internal final func addField (_ accessType : X3DAccessType, _ name : String, _ field : X3DField)
   {
      field .isTainted = true
      field .addParent (self)

      field .identifier = name
      field .accessType = accessType
      
      // Add to field set
      
      fieldIndex [name] = field
      fields .append (field)
      
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
      
      if fieldIndex [name]! .accessType == .inputOutput
      {
         aliases ["set_" + alias]    = name
         aliases [alias + "changed"] = name
      }
   }
   
   private final var numUserDefinedFields : Int = 0
   
   public final var preDefinedFields : ArraySlice <X3DField>
   {
      return fields [..<(fields .count - numUserDefinedFields)]
   }
   
   public final var userDefinedFields : ArraySlice <X3DField>
   {
      return fields [(fields .count - numUserDefinedFields)...]
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
         if field .accessType == .inputOutput
         {
            return field
         }
      }
      
      if let field = fieldIndex [name + "_changed"]
      {
         if field .accessType == .inputOutput
         {
            return field
         }
      }

      throw X3DError .INVALID_X3D (t("Unknown field '%@' in class '%@'.", name, typeName))
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
      
      field .isSet = true

      guard !field .isTainted else { return }

//      debugPrint (#file, #function, typeName, field .identifier)

      field .isTainted = true

      addEventObject (for: field, event: X3DEvent (field))
   }

   internal final override func addEventObject (for field : X3DField, event : X3DEvent)
   {
      // Register field for processEvent.
      
      field .isSet = true
      
      browser! .addTaintedField (field: field, event: event)

      guard field .isInput || (extendedEventHandling && !field .isOutput) else { return }

      addNodeEvent ()
   }
   
   internal final func addNodeEvent ()
   {
      guard !isTainted else { return }

      isTainted = true

      // Register node for processEvents.
      
      browser! .addTaintedNode (node: self)
      browser! .setNeedsDisplay ()
   }
   
   internal final func processEvents ()
   {
      isTainted = false

      processInterests ()
   }
   
   // Convert to string
   
   internal override func toStream (_ stream : X3DOutputStream)
   {
      stream += typeName + " { }"
   }

   // Destruction
   
   deinit
   {
      //debugPrint (#file, #function, Swift .type (of: self))
      
      for child in children
      {
         child .removeParent (self)
      }
      
      for field in fields
      {
         field .removeParent (self)
      }

      if !identifier .isEmpty
      {
         executionContext? .removeNamedNode (name: identifier)
      }
   }
}
