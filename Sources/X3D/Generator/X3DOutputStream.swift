//
//  X3DOutputStream.swift
//  X3D
//
//  Created by Holger Seelig on 04.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public enum OutputStyle
{
   case Smallest
   case Small
   case Compact
   case Tidy
}

internal final class X3DOutputStream
{
   // Member types
   
   // Construction
   
   internal init (style : OutputStyle)
   {
      switch style
      {
         case .Smallest:
            Space                = " "
            TidySpace            = ""
            Break                = " "
            TidyBreak            = ""
            ListBreak            = ""
            Comma                = " "
            IndentCharacters     = ""
            TidyIndentCharacters = ""
         case .Small:
            Space                = " "
            TidySpace            = ""
            Break                = "\n"
            TidyBreak            = "\n"
            ListBreak            = ""
            Comma                = ","
            IndentCharacters     = ""
            TidyIndentCharacters = ""
        case .Compact:
            Space                = " "
            TidySpace            = " "
            Break                = "\n"
            TidyBreak            = "\n"
            ListBreak            = " "
            Comma                = ","
            IndentCharacters     = "  "
            TidyIndentCharacters = ""
         case .Tidy:
            Space                = " "
            TidySpace            = " "
            Break                = "\n"
            TidyBreak            = "\n"
            ListBreak            = "\n"
            Comma                = ","
            IndentCharacters     = "  "
            TidyIndentCharacters = "  "
      }
   }
   
   // String handling
   
   internal private(set) final var string : String = ""
   
   @inlinable
   internal static func += (stream : X3DOutputStream, string : String)
   {
      stream .string += string
   }
   
   // Spaces
   
   internal private(set) final var Space     : String
   internal private(set) final var TidySpace : String
   internal private(set) final var Break     : String
   internal private(set) final var TidyBreak : String
   internal private(set) final var ListBreak : String
   internal private(set) final var Comma     : String

   @inlinable
   internal final var Separator : String { Comma + ListBreak + TidyIndent }

   // Indent handling
   
   private final var IndentCharacters     : String
   private final var TidyIndentCharacters : String

   internal private(set) final var Indent     : String = ""
   internal private(set) final var TidyIndent : String = ""

   internal final func incIndent ()
   {
      Indent     += IndentCharacters
      TidyIndent += TidyIndentCharacters
   }
   
   internal final func decIndent ()
   {
      Indent     .removeLast (IndentCharacters     .count)
      TidyIndent .removeLast (TidyIndentCharacters .count)
   }
   
   // Pad
   
   internal final func padding (_ string : String, _ count : Int) -> String
   {
      return string .padding (toLength: count, withPad: TidySpace, startingAt: 0)
   }

   // Execution context handling
   
   @inlinable
   internal var executionContext : X3DExecutionContext { executionContexts .last! }

   private var executionContexts = [X3DExecutionContext] ()
   
   @inlinable
   internal final func push (_ executionContext : X3DExecutionContext)
   {
      executionContexts .append (executionContext)
   }
   
   @inlinable
   internal final func pop (_ executionContext : X3DExecutionContext)
   {
      executionContexts .removeLast ()
   }
   
   // Scope handling
   
   internal final func enterScope ()
   {
      
   }
   
   internal final func leaveScope ()
   {
      
   }
   
   @inlinable
   internal final func isSharedNode (_ node : X3DNode) -> Bool
   {
      return false
   }
   
   private final var nodes = Set <X3DNode> ()
   
   @inlinable
   internal final func addNode (_ node : X3DNode)
   {
      nodes .insert (node)
   }
   
   @inlinable
   internal final func existsNode (_ node : X3DNode) -> Bool
   {
      return nodes .contains (node)
   }
   
   internal final func getName (_ node : X3DNode) -> String
   {
      return node .getName ()
   }
}
