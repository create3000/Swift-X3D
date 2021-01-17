//
//  X3DNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import Foundation

public class X3DNode :
   X3DBaseNode
{
   // Common properties
   
   internal class var component : String { "Sunrise" }
   internal class var componentLevel : Int32 { 0 }
   internal class var containerField : String { "sunrise" }
   
   // Common properties
   
   public final func getComponent () -> String { Self .component }
   public final func getComponentLevel () -> Int32 { Self .componentLevel }
   public final func getContainerField () -> String { Self .containerField }
   
   // Fields

   @SFNode public final var metadata : X3DNode?
   
   // Properties
   
   internal func getSourceText () -> MFString? { nil }

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DNode)
   }
   
   internal func create (with executionContext : X3DExecutionContext) -> X3DNode
   {
      assert (false, "'\(getTypeName ()).create' is not supported.")
      return self
   }
   
   /// Copies this node into prototype instance.
   internal final func copy (with protoInstance : X3DPrototypeInstance) -> X3DNode
   {
      let body = protoInstance .getBody ()
      
      if let namedNode = try? body .getNamedNode (name: getName ())
      {
         return namedNode
      }
      
      let copy = self .create (with: body)
      
      if !getName () .isEmpty
      {
         try! body .updateNamedNode (name: getName (), node: copy)
      }
      
      // Pre defined fields
      
      for preDefinedField in getPreDefinedFields ()
      {
         guard let field = try? copy .getField (name: preDefinedField .getName ()) else
         {
            continue
         }
         
         guard field .getAccessType () == preDefinedField .getAccessType () && field .getType () == preDefinedField .getType () else
         {
            continue
         }
         
         field .isSet = preDefinedField .isSet

         if preDefinedField .references .count == 0
         {
            if preDefinedField .isInitializable
            {
               field .set (with: protoInstance, value: preDefinedField)
            }
         }
         else
         {
            // IS relationship
            
            for originalReference in preDefinedField .references .allObjects
            {
               guard let reference = try? protoInstance .getField (name: originalReference .getName ()) else
               {
                  continue
               }

               field .addReference (to: reference)
            }
         }
      }
      
      // User defined fields from Script and Shader
      
      for userDefinedField in getUserDefinedFields ()
      {
         let field = userDefinedField .copy ()
         
         copy .addUserDefinedField (userDefinedField .getAccessType (), userDefinedField .getName (), field)
         
         field .isSet = userDefinedField .isSet

         if userDefinedField .references .count == 0
         {
            if userDefinedField .isInitializable
            {
               field .set (with: protoInstance, value: userDefinedField)
            }
         }
         else
         {
            // IS relationship

            for originalReference in userDefinedField .references .allObjects
            {
               guard let reference = try? protoInstance .getField (name: originalReference .getName ()) else
               {
                  continue
               }
               
               field .addReference (to: reference)
            }
         }
      }
      
      copy .setup ()
      
      return copy
   }
 
   // Prototype handling
   
   /// Returns the innermost node of an X3DPrototypeInstance or self.
   internal var innerNode : X3DNode? { self }
   
   // Misc
   
   public final var cloneCount : Int
   {
      var count = 0
      
      for parent in parents .allObjects
      {
         var c = 1
         
         if let field = parent as? MFNode <X3DNode>
         {
            c = field .wrappedValue .reduce (0, { r, n in n === self ? r + 1 : r })
         }
         
         for parent in parent .parents .allObjects
         {
            if let node = parent as? X3DNode,
               !node .isPrivate
            {
               count += c
            }
            else if let executionContext = parent as? X3DExecutionContext,
                    !executionContext .isPrivate
            {
               count += c
            }
         }
      }
      
      return count
   }
      
   public final func getDisplayName () -> String { remove_trailing_number (getName ()) }
   
   public func isDefaultValue (_ field : X3DField) -> Bool
   {
      let node = create (with: executionContext!)
      
      guard let other = try? node .getField (name: field .getName ()) else
      {
         return false
      }
      
      return other .equals (to: field)
   }
   
   private final func getChangedFields () -> [X3DField]
   {
      var changedFields = [X3DField] ()

      for field in getPreDefinedFields ()
      {
         if field .references .allObjects .isEmpty
         {
            if !field .isInitializable
            {
               continue
            }

            if isDefaultValue (field)
            {
               continue
            }
         }

         changedFields .append (field)
      }

      return changedFields
   }

   // Input/Output
   
   internal override func toXMLStream (_ stream : X3DOutputStream)
   {
      stream += "<\(getTypeName ())/>"
   }

   internal override func toJSONStream (_ stream : X3DOutputStream)
   {
      stream += getTypeName ()
   }

   internal override func toVRMLStream (_ stream : X3DOutputStream)
   {
      guard !stream .isSharedNode (self) else
      {
         stream += "NULL"
         return
      }
      
      stream .enterScope ()
      
      defer { stream .leaveScope () }
      
      let name = stream .getName (self)
      
      if !name .isEmpty
      {
         // Clone
         
         if stream .existsNode (self)
         {
            stream += "USE"
            stream += " "
            stream += name

            return
         }
         
         // Name
         
         stream .addNode (self)

         stream += "DEF"
         stream += " "
         stream += name
         stream += " "
      }
      
      // Type name

      stream += getTypeName ()
      stream += " "
      stream += "{"
      
      // User-defined fields
      
      let userDefinedFields = getUserDefinedFields ()
      let fields            = getChangedFields ()
      
      var fieldTypeLength   = 0
      var accessTypeLength  = 0
      
      if canUserDefinedFields
      {
         for field in userDefinedFields
         {
            fieldTypeLength  = max (fieldTypeLength,  field .getTypeName () .count)
            accessTypeLength = max (accessTypeLength, field .getAccessType () .description .count)
         }

         if !userDefinedFields .isEmpty
         {
            stream += "\n"
            
            stream .incIndent ()

            for field in userDefinedFields
            {
               toVRMLStreamUserDefinedField (stream, field, fieldTypeLength, accessTypeLength)

               stream += "\n"
            }

            stream .decIndent ()
            
            if !fields .isEmpty
            {
               stream += "\n"
            }
         }
      }

      // Fields
      
      if fields .isEmpty
      {
         if userDefinedFields .isEmpty
         {
            stream += " "
         }
         else
         {
            stream += stream .indent
         }
      }
      else
      {
         if userDefinedFields .isEmpty
         {
            stream += "\n"
         }

         stream .incIndent ()

         for field in fields
         {
            toVRMLStreamField (stream, field, fieldTypeLength, accessTypeLength)

            stream += "\n"
         }

         stream .decIndent ()
         
         stream += stream .indent
      }

      // End
      
      stream += "}"
   }
   
   private final func toVRMLStreamUserDefinedField (_ stream : X3DOutputStream, _ field : X3DField, _ fieldTypeLength : Int, _ accessTypeLength : Int)
   {
      let references = field .references .allObjects
      
      if references .isEmpty
      {
         stream += stream .indent
         stream += stream .padRight (field .getAccessType () .description, accessTypeLength)
         stream += " "
         stream += stream .padRight (field .getTypeName (), fieldTypeLength)
         stream += " "
         stream += field .getName ()

         if field .isInitializable
         {
            stream += " "

            field .toVRMLStream (stream)
         }
      }
      else
      {
         var initializableReference = false
         var i                      = 0

         for reference in references
         {
            initializableReference = initializableReference || reference .isInitializable

            // Output user defined reference field

            stream += stream .indent
            stream += stream .padRight (field .getAccessType () .description, accessTypeLength)
            stream += " "
            stream += stream .padRight (field .getTypeName (), fieldTypeLength)
            stream += " "
            stream += field .getName ()
            stream += " "
            stream += "IS"
            stream += " "
            stream += reference .getName ()

            i += 1

            if i != references .count
            {
               stream += "\n"
            }
         }

         if field .getAccessType () == .inputOutput && !initializableReference && !isDefaultValue (field)
         {
            stream += "\n"
            stream += stream .indent
            stream += stream .padRight (field .getAccessType () .description, accessTypeLength)
            stream += " "
            stream += stream .padRight (field .getTypeName (), fieldTypeLength)
            stream += " "
            stream += field .getName ()

            if field .isInitializable
            {
               stream += " "

               field .toVRMLStream (stream)
            }
         }
      }
   }
   
   private final func toVRMLStreamField (_ stream : X3DOutputStream, _ field : X3DField, _ fieldTypeLength : Int, _ accessTypeLength : Int)
   {
      let references = field .references .allObjects
      
      if references .isEmpty
      {
         if field .isInitializable
         {
            stream += stream .indent
            stream += field .getName ()
            stream += " "

            field .toVRMLStream (stream)
         }
      }
      else
      {
         var initializableReference = false
         var i                      = 0

         for reference in references
         {
            initializableReference = initializableReference || reference .isInitializable

            // Output build in reference field

            stream += stream .indent
            stream += field .getName ()
            stream += " "
            stream += "IS"
            stream += " "
            stream += reference .getName ()

            i += 1

            if i != references .count
            {
               stream += "\n"
            }
         }

         if field .getAccessType () == .inputOutput && !initializableReference && !isDefaultValue (field)
         {
            // Output build in field

            stream += "\n"
            stream += stream .indent
            stream += field .getName ()
            stream += " "

            field .toVRMLStream (stream)
         }
      }
   }
}
