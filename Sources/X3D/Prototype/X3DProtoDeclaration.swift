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
      
      body .setup ()
   }
   
   // Input/Output
   
   internal final override func toXMLStream (_ stream : X3DOutputStream)
   {
      stream += stream .Indent
      stream += "<ProtoDeclare"
      stream += stream .Space
      stream += "name='"
      stream += getName () .escapeXML
      stream += "'"
      stream += ">"
      stream += stream .TidyBreak

      // <ProtoInterface>

      stream .enterScope ()

      let userDefinedFields = getUserDefinedFields ()

      if !userDefinedFields .isEmpty
      {
         stream .incIndent ()
         
         stream += stream .Indent
         stream += "<ProtoInterface>"
         stream += stream .TidyBreak
         
         stream .incIndent ()

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
                     
                     stream .incIndent ()
                     
                     field .toXMLStream (stream)
                     
                     stream += stream .TidyBreak
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

         stream .decIndent ()
         
         stream += stream .Indent
         stream += "</ProtoInterface>"
         stream += stream .TidyBreak
         
         stream .decIndent ()
      }

      stream .leaveScope ()

      // </ProtoInterface>

      // <ProtoBody>

      stream .incIndent ()
      
      stream += stream .Indent
      stream += "<ProtoBody>"
      stream += stream .TidyBreak
      
      stream .incIndent ()

      body .toXMLStream (stream)

      stream .decIndent ()
      
      stream += stream .Indent
      stream += "</ProtoBody>"
      stream += stream .TidyBreak
      
      stream .decIndent ()

      // </ProtoBody>

      stream += stream .Indent
      stream += "</ProtoDeclare>"
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

         stream .incIndent ()

         for field in userDefinedFields
         {
            toVRMLStreamUserDefinedField (stream, field, fieldTypeLength, accessTypeLength)
            
            stream += field === userDefinedFields .last ? stream .TidyBreak : stream .Break
         }

         stream .decIndent ()

         stream += stream .Indent
      }

      stream .leaveScope ()

      stream += "]"
      stream += stream .TidyBreak

      stream += stream .Indent
      stream += "{"
      stream += stream .TidyBreak

      stream .incIndent ()

      body .toVRMLStream (stream)

      stream .decIndent ()

      stream += stream .Indent
      stream += "}"
   }
   
   private final func toVRMLStreamUserDefinedField (_ stream : X3DOutputStream, _ field : X3DField, _ fieldTypeLength : Int, _ accessTypeLength : Int)
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
}
