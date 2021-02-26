//
//  X3DProtoDeclaration.swift
//  X3D
//
//  Created by Holger Seelig on 27.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public final class X3DProtoDeclaration :
   X3DProtoDeclarationNode
{
   // Common properties
   
   internal final override class var typeName : String { "X3DProtoDeclaration" }
   
   // Properties
   
   public final override var proto : X3DProtoDeclaration? { self }
   public final let body           : X3DExecutionContext
   
   // Construction
   
   internal init (executionContext : X3DExecutionContext)
   {
      self .body = X3DExecutionContext (executionContext .browser!, executionContext)
      
      super .init (executionContext .browser!, executionContext)
   }
   
   internal override func initialize ()
   {
      super .initialize ()
      
      body .addParent (self)
      
      body .setup ()
   }
   
   // Input/Output
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      stream += stream .Indent
      stream += "<ProtoDeclare"
      stream += stream .Space
      stream += "name='"
      stream += getName () .toXMLString ()
      stream += "'"
      stream += ">"
      stream += stream .TidyBreak

      // <ProtoInterface>

      stream .enterScope ()

      let userDefinedFields = getUserDefinedFields ()

      if !userDefinedFields .isEmpty
      {
         stream += stream .IncIndent ()
         stream += stream .Indent
         stream += "<ProtoInterface>"
         stream += stream .TidyBreak
         stream += stream .IncIndent ()

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
            stream += field .getName () .toXMLString ()
            stream += "'"

            if field .isDefaultValue
            {
               stream += "/>"
               stream += stream .TidyBreak
            }
            else
            {
               switch field .getType ()
               {
                  case .SFNode, .MFNode: do
                  {
                     stream .containerFields .append (field)

                     stream += ">"
                     stream += stream .TidyBreak
                     stream += stream .IncIndent ()
                     stream += stream .toXMLStream (field)
                     stream += stream .TidyBreak
                     stream += stream .DecIndent ()
                     stream += stream .Indent
                     stream += "</field>"
                     stream += stream .TidyBreak

                     stream .containerFields .removeLast ()
                  }
                  default: do
                  {
                     stream += stream .Space
                     stream += "value='"
                     stream += stream .toXMLStream (field)
                     stream += "'"
                     stream += "/>"
                     stream += stream .TidyBreak
                  }
               }
            }
         }

         stream += stream .DecIndent ()
         stream += stream .Indent
         stream += "</ProtoInterface>"
         stream += stream .TidyBreak
         stream += stream .DecIndent ()
      }

      stream .leaveScope ()

      // </ProtoInterface>

      // <ProtoBody>
      
      stream .push (self)

      stream += stream .IncIndent ()
      stream += stream .Indent
      stream += "<ProtoBody>"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      stream += stream .toXMLStream (body)
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "</ProtoBody>"
      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      
      stream .pop (self)

      // </ProtoBody>

      stream += stream .Indent
      stream += "</ProtoDeclare>"
   }

   internal final override func toJSONStream (_ stream : X3DOutputStream)
   {
      stream += "{"
      stream += stream .TidySpace
      stream += "\""
      stream += "ProtoDeclare"
      stream += "\""
      stream += ":"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      stream += stream .Indent
      stream += "{"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      stream += stream .Indent
      stream += "\""
      stream += "@name"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "\""
      stream += getName () .toJSONString ()
      stream += "\""
      stream += ","
      stream += stream .TidyBreak

      stream += stream .Indent
      stream += "\""
      stream += "ProtoInterface"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "{"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()

      // Fields
      
      stream .enterScope ()
      stream .lastProperties .append (false)

      let userDefinedFields = getUserDefinedFields ()

      if !userDefinedFields .isEmpty
      {
         if stream .lastProperty
         {
            stream += ","
            stream += stream .TidyBreak
         }

         stream += stream .Indent
         stream += "\""
         stream += "field"
         stream += "\""
         stream += ":"
         stream += stream .TidySpace
         stream += "["
         stream += stream .TidyBreak
         stream += stream .IncIndent ()

         for i in 0 ..< userDefinedFields .count
         {
            let field = userDefinedFields [i]
            
            stream += stream .Indent
            stream += "{"
            stream += stream .TidyBreak
            stream += stream .IncIndent ()

            stream += stream .Indent
            stream += "\""
            stream += "@accessType"
            stream += "\""
            stream += ":"
            stream += stream .TidySpace
            stream += "\""
            stream += field .getAccessType () .description
            stream += "\""
            stream += ","
            stream += stream .TidyBreak

            stream += stream .Indent
            stream += "\""
            stream += "@type"
            stream += "\""
            stream += ":"
            stream += stream .TidySpace
            stream += "\""
            stream += field .getTypeName ()
            stream += "\""
            stream += ","
            stream += stream .TidyBreak

            stream += stream .Indent
            stream += "\""
            stream += "@name"
            stream += "\""
            stream += ":"
            stream += stream .TidySpace
            stream += "\""
            stream += field .getName () .toJSONString ()
            stream += "\""

            if field .isDefaultValue
            {
               stream += stream .TidyBreak
            }
            else
            {
               stream += ","
               stream += stream .TidyBreak

               // Output value
      
               switch field .getType ()
               {
                  case .MFNode: do
                  {
                     stream += stream .Indent
                     stream += "\""
                     stream += "-children"
                     stream += "\""
                     stream += ":"
                     stream += stream .TidySpace
                     stream += stream .toJSONStream (field)
                     stream += stream .TidyBreak
                  }
                  case .SFNode: do
                  {
                     stream += stream .Indent
                     stream += "\""
                     stream += "-children"
                     stream += "\""
                     stream += ":"
                     stream += stream .TidySpace
                     stream += "["
                     stream += stream .TidyBreak
                     stream += stream .IncIndent ()
                     stream += stream .Indent
                     stream += stream .toJSONStream (field)
                     stream += stream .TidyBreak
                     stream += stream .DecIndent ()
                     stream += stream .Indent
                     stream += "]"
                     stream += stream .TidyBreak
                  }
                  default: do
                  {
                     stream += stream .Indent
                     stream += "\""
                     stream += "@value"
                     stream += "\""
                     stream += ":"
                     stream += stream .TidySpace
                     stream += stream .toJSONStream (field)
                     stream += stream .TidyBreak
                  }
               }
            }

            stream += stream .DecIndent ()
            stream += stream .Indent
            stream += "}"

            if i != userDefinedFields .count - 1
            {
               stream += ","
            }

            stream += stream .TidyBreak
         }

         stream += stream .DecIndent ()
         stream += stream .Indent
         stream += "]"

         stream .lastProperty = true
      }

      stream += stream .DecIndent ()
      stream += stream .TidyBreak
      stream += stream .Indent
      stream += "}"
      stream += ","
      stream += stream .TidyBreak

      stream .leaveScope ()

      // ProtoBody

      stream += stream .Indent
      stream += "\""
      stream += "ProtoBody"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "{"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()

      stream += stream .Indent
      stream += "\""
      stream += "-children"
      stream += "\""
      stream += ":"
      stream += stream .TidySpace
      stream += "["
      stream += stream .TidyBreak
      stream += stream .IncIndent ()

      stream .push (self)
      stream .lastProperties .append (false)
      
      body .toJSONStream (stream)
      
      stream .lastProperties .removeLast ()
      stream .pop (self)

      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "]"
      stream += stream .TidyBreak

      // End

      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
      stream += stream .TidyBreak
      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
      
      stream .lastProperties .removeLast ()
   }
   
   internal final override func toVRMLStream (_ stream : X3DOutputStream)
   {
      stream += stream .Indent
      stream += "PROTO"
      stream += stream .Space
      stream += getName ()
      stream += stream .TidySpace
      stream += "["

      stream .enterScope ()

      let userDefinedFields = getUserDefinedFields ()

      if userDefinedFields .isEmpty
      {
         stream += stream .TidySpace
      }
      else
      {
         var fieldTypeLength  = 0
         var accessTypeLength = 0
         
         for field in userDefinedFields
         {
            fieldTypeLength  = max (fieldTypeLength, field .getTypeName () .count)
            accessTypeLength = max (accessTypeLength, field .getAccessType () .description .count)
         }

         stream += stream .TidyBreak
         stream += stream .IncIndent ()

         for field in userDefinedFields
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

            stream += field === userDefinedFields .last ? stream .TidyBreak : stream .Break
         }

         stream += stream .DecIndent ()
         stream += stream .Indent
      }

      stream .leaveScope ()

      stream += "]"
      stream += stream .TidyBreak
      stream += stream .Indent
      stream += "{"
      stream += stream .TidyBreak
      stream += stream .IncIndent ()
      
      stream .push (self)

      body .toVRMLStream (stream)
      
      stream .pop (self)

      stream += stream .DecIndent ()
      stream += stream .Indent
      stream += "}"
   }
}
