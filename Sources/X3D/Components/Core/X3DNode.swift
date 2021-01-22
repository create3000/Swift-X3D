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
      let body = protoInstance .body!
      
      if let namedNode = try? body .getNamedNode (name: getName ())
      {
         return namedNode
      }
      
      let copy = self .create (with: body)
      
      if !getName () .isEmpty
      {
         try! body .updateNamedNode (name: getName (), node: copy)
      }
      
      // Pre-defined fields
      
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
   
   public final func getDisplayName () -> String { remove_trailing_number (getName ()) }
   
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
   
   // Field handling
   
   public final var hasRoutes : Bool
   {
      for field in getFieldDefinitions ()
      {
         if field .inputRoutes .allObjects .count > 0
         {
            return true
         }
         
         if field .outputRoutes .allObjects .count > 0
         {
            return true
         }
      }
      
      return false
   }

   public func isDefaultValue (fieldName : String) throws -> Bool
   {
      let field          = try getField (name: fieldName)
      let nodeDefinition = browser! .getNodeDefinition (typeName: getTypeName ())
      
      guard let other = try? nodeDefinition .getField (name: fieldName) else
      {
         return false
      }
      
      return other .equals (to: field)
   }
   
   internal final func getChangedFields () -> [X3DField]
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

            if try! isDefaultValue (fieldName: field .getName ())
            {
               continue
            }
         }

         changedFields .append (field)
      }

      return changedFields
   }

   // Input/Output
   
   internal override func toStream (_ stream : X3DOutputStream)
   {
      stream += getTypeName ()
      stream += stream .Space
      stream += "{ }"
   }

   internal override func toXMLStream (_ stream : X3DOutputStream)
   {
      guard !stream .isSharedNode (self) else
      {
         stream += stream .Indent
         stream += "<!-- NULL -->"
         return
      }
      
      stream .enterScope ()
      
      defer { stream .leaveScope () }
      
      let name = stream .getName (self)
      
      if !name .isEmpty
      {
         if stream .existsNode (self)
         {
            stream += stream .Indent
            stream += "<"
            stream += getTypeName ()
            stream += stream .Space
            stream += "USE='"
            stream += name .escapeXML
            stream += "'"
            
            if let containerField = stream .containerField
            {
               if containerField .getName () != getContainerField ()
               {
                  stream += stream .Space
                  stream += "containerField='"
                  stream += containerField .getName () .escapeXML
                  stream += "'"
               }
            }

            stream += "/>"
            return
         }
      }
      
      stream += stream .Indent
      stream += "<"
      stream += getTypeName ()

      if !name .isEmpty
      {
         stream .addNode (self)

         stream += stream .Space
         stream += "DEF='"
         stream += name .escapeXML
         stream += "'"
      }
      
      if let containerField = stream .containerField
      {
         if containerField .getName () != getContainerField ()
         {
            stream += stream .Space
            stream += "containerField='"
            stream += containerField .getName () .escapeXML
            stream += "'"
         }
      }

      let fields            = getChangedFields ()
      let userDefinedFields = getUserDefinedFields ()

      var references = [X3DField] ()
      var childNodes = [X3DField] ()

      var sourceText = getSourceText ()

      if sourceText != nil,
         sourceText! .wrappedValue .isEmpty
      {
         sourceText = nil
      }
      
      stream .incIndent ()
      stream .incIndent ()
      
      for field in fields
      {
         if !stream .metadata && field === $metadata
         {
            continue
         }
         
         if field .references .allObjects .isEmpty
         {
            if field .isInitializable
            {
               switch field .getType ()
               {
                  case .SFNode, .MFNode: do
                  {
                     childNodes .append (field)
                  }
                  default: do
                  {
                     guard field != sourceText else { break }
                  
                     stream += stream .Break
                     stream += stream .Indent
                     stream += field .getName ()
                     stream += "='"
                     
                     field .toXMLStream (stream)
                     
                     stream += "'"
                  }
               }
            }
         }
         else
         {
            references .append (field)
         }
      }
      
      stream .decIndent ()
      stream .decIndent ()
      
      if (!canUserDefinedFields || userDefinedFields .isEmpty) && references .isEmpty && childNodes .isEmpty && sourceText == nil
      {
         stream += "/>";
      }
      else
      {
         stream += ">"
         stream += stream .TidyBreak
         
         stream .incIndent ()
         
         if canUserDefinedFields
         {
            for field in userDefinedFields
            {
               stream += stream .Indent
               stream += "<field"
               stream += stream .Space
               stream += "accessType='"
               stream += field .getAccessType () .description
               stream += "'"
               stream += stream .Space
               stream += "type='"
               stream += field .getTypeName ()
               stream += "'"
               stream += stream .Space
               stream += "name='"
               stream += field .getName () .escapeXML
               stream += "'"
               
               if field .references .allObjects .isEmpty
               {
                  if !field .isInitializable /* || field .isDefaultValue */
                  {
                     stream += "/>"
                     stream += stream .TidyBreak
                  }
                  else
                  {
                     // Output value

                     switch field .getType ()
                     {
                        case .SFNode, .MFNode: do
                        {
                           stream .containerFields .append (field)

                           stream += ">"
                           stream += stream .TidyBreak
                           
                           stream .incIndent ()
                           
                           field .toXMLStream (stream)
                           
                           stream .decIndent ()
                           
                           stream += stream .Indent
                           stream += "</field>"
                           stream += stream .TidyBreak
                           
                           stream .containerFields .removeLast ()
                        }
                        default: do
                        {
                           stream += stream .Space
                           stream += "value='"
                           
                           field .toXMLStream (stream)
                           
                           stream += "'"
                           stream += "/>"
                           stream += stream .TidyBreak
                        }
                     }
                  }
               }
               else
               {
                  references .append (field)

                  stream += "/>"
                  stream += stream .TidyBreak
               }
            }
         }
         
         if !references .isEmpty
         {
            stream += stream .Indent
            stream += "<IS>"
            stream += stream .TidyBreak
            
            stream .incIndent ()

            for field in references
            {
               for reference in field .references .allObjects
               {
                  stream += stream .Indent
                  stream += "<connect"
                  stream += stream .Space
                  stream += "nodeField='"
                  stream += field .getName () .escapeXML
                  stream += "'"
                  stream += stream .Space
                  stream += "protoField='"
                  stream += reference .getName () .escapeXML
                  stream += "'"
                  stream += "/>"
                  stream += stream .TidyBreak;
               }
            }

            stream .decIndent ()
            
            stream += stream .Indent
            stream += "</IS>"
            stream += stream .TidyBreak
         }

         for field in childNodes
         {
            stream .containerFields .append (field)

            field .toXMLStream (stream)
 
            stream .containerFields .removeLast ()
         }

         if let sourceText = sourceText
         {
            for value in sourceText .wrappedValue
            {
               stream += "<![CDATA["
               stream += value
               stream += "]]>"
               stream += stream .TidyBreak;
            }
         }

         stream .decIndent ()
         
         stream += stream .Indent
         stream += "</"
         stream += getTypeName ()
         stream += ">"
      }
   }

   internal override func toJSONStream (_ stream : X3DOutputStream)
   {
      stream += getTypeName ()
   }

   internal final override func toVRMLStream (_ stream : X3DOutputStream)
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
            stream += stream .Space
            stream += name

            return
         }
         
         // Name
         
         stream .addNode (self)

         stream += "DEF"
         stream += stream .Space
         stream += name
         stream += stream .Space
      }
      
      // Type name

      stream += getTypeName ()
      stream += stream .TidySpace
      stream += "{"
      
      // User-defined fields
      
      let userDefinedFields = getUserDefinedFields ()
      var fields            = getChangedFields ()
      
      if !stream .metadata
      {
         fields = fields .filter { $0 !== $metadata }
      }

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
            stream += stream .TidyBreak
            
            stream .incIndent ()

            for field in userDefinedFields
            {
               toVRMLStreamUserDefinedField (stream, field, fieldTypeLength, accessTypeLength)

               if field !== userDefinedFields .last
               {
                  stream += stream .Break
               }
            }
            
            if fields .isEmpty
            {
               stream += stream .TidyBreak
            }
            else
            {
               stream += stream .Break
            }

            stream .decIndent ()
            
            if !fields .isEmpty
            {
               stream += stream .TidyBreak
            }
         }
      }

      // Fields
      
      if fields .isEmpty
      {
         if userDefinedFields .isEmpty
         {
            stream += stream .TidySpace
         }
         else
         {
            stream += stream .Indent
         }
      }
      else
      {
         if userDefinedFields .isEmpty
         {
            stream += stream .TidyBreak
         }

         stream .incIndent ()

         for field in fields
         {
            toVRMLStreamField (stream, field, fieldTypeLength, accessTypeLength)

            if field !== fields .last
            {
               stream += stream .Break
            }
         }
         
         stream += stream .TidyBreak

         stream .decIndent ()
         
         stream += stream .Indent
      }

      // End
      
      stream += "}"
   }
   
   private final func toVRMLStreamUserDefinedField (_ stream : X3DOutputStream, _ field : X3DField, _ fieldTypeLength : Int, _ accessTypeLength : Int)
   {
      let references = field .references .allObjects
      
      if references .isEmpty
      {
         stream += stream .Indent
         stream += stream .padding (field .getAccessType () .description, accessTypeLength)
         stream += stream .Space
         stream += stream .padding (field .getTypeName (), fieldTypeLength)
         stream += stream .Space
         stream += field .getName ()

         if field .isInitializable
         {
            if let array = field as? X3DArrayField,
               array .count != 1
            {
               stream += stream .TidySpace
            }
            else
            {
               stream += stream .Space
            }

            field .toVRMLStream (stream)
         }
      }
      else
      {
         var i = 0

         for reference in references
         {
            // Output user defined reference field

            stream += stream .Indent
            stream += stream .padding (field .getAccessType () .description, accessTypeLength)
            stream += stream .Space
            stream += stream .padding (field .getTypeName (), fieldTypeLength)
            stream += stream .Space
            stream += field .getName ()
            stream += stream .Space
            stream += "IS"
            stream += stream .Space
            stream += reference .getName ()

            i += 1

            if i != references .count
            {
               stream += stream .Break
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
            stream += stream .Indent
            stream += field .getName ()
            
            if let array = field as? X3DArrayField,
               array .count != 1
            {
               stream += stream .TidySpace
            }
            else
            {
               stream += stream .Space
            }

            field .toVRMLStream (stream)
         }
      }
      else
      {
         var i = 0

         for reference in references
         {
            // Output build in reference field

            stream += stream .Indent
            stream += field .getName ()
            stream += stream .Space
            stream += "IS"
            stream += stream .Space
            stream += reference .getName ()

            i += 1

            if i != references .count
            {
               stream += stream .Break
            }
         }
      }
   }
}
