//
//  X3DOutputStream.swift
//  X3D
//
//  Created by Holger Seelig on 04.10.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public enum X3DOutputStyle
{
   case Clean
   case Small
   case Compact
   case Tidy
   
   private static let styles : [String : Self] = [
      "clean"   : .Clean,
      "small"   : .Small,
      "compact" : .Compact,
      "tidy"    : .Tidy,
   ]
   
   init? (_ string : String)
   {
      guard let value = Self .styles [string .lowercased ()] else { return nil }
      
      self = value
   }
}

public final class X3DOutputStream
{
   // Construction
   
   public init (style : X3DOutputStyle = .Tidy)
   {
      self .style = style
      
      set (style: style)
   }
   
   // Style
   
   public final var style : X3DOutputStyle
   {
      didSet { set (style: style) }
   }
   
   private final func set (style : X3DOutputStyle)
   {
      switch style
      {
         case .Clean:
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
            TidyIndentCharacters = IndentCharacters
      }
   }

   
   // String handling
   
   internal private(set) final var string : String = ""
   
   internal static func += (stream : X3DOutputStream, string : String)
   {
      stream .string += string
   }
   
   // Spaces
   
   internal private(set) final var Space     : String = ""
   internal private(set) final var TidySpace : String = ""
   internal private(set) final var Break     : String = ""
   internal private(set) final var TidyBreak : String = ""
   internal private(set) final var ListBreak : String = ""
   internal private(set) final var Comma     : String = ""

   internal final var ListSeparator : String { Comma + ListBreak + TidyIndent }

   // Indent handling
   
   private final var IndentCharacters     : String = ""
   private final var TidyIndentCharacters : String = ""

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
      if TidySpace .isEmpty
      {
         return string
      }
      else
      {
         return string .padding (toLength: count, withPad: TidySpace, startingAt: 0)
      }
   }

   // Execution context handling
   
   internal final var executionContext : X3DExecutionContext { executionContexts .last! }

   private final var executionContexts = [X3DExecutionContext] ()
   
   private final var names         = NSMapTable <X3DExecutionContext, NSHashTable <NSString>> ()
   private final var importedNodes = NSMapTable <X3DExecutionContext, NSHashTable <X3DNode>> ()
   private final var exportedNodes = NSMapTable <X3DExecutionContext, NSHashTable <X3DNode>> ()

   internal final func push (_ executionContext : X3DExecutionContext)
   {
      executionContexts .append (executionContext)
      
      if names .object (forKey: executionContext) == nil
      {
         names .setObject (NSHashTable <NSString> (), forKey: executionContext)
      }

      if importedNodes .object (forKey: executionContext) == nil
      {
         importedNodes .setObject (NSHashTable <X3DNode> (), forKey: executionContext)
      }

      if exportedNodes .object (forKey: executionContext) == nil
      {
         exportedNodes .setObject (NSHashTable <X3DNode> (), forKey: executionContext)
      }
   }
   
   internal final func pop (_ executionContext : X3DExecutionContext)
   {
      executionContexts .removeLast ()
      
      guard executionContexts .isEmpty else { return }

      importedNodes .removeAllObjects ()
      exportedNodes .removeAllObjects ()
   }
   
   // Scope handling
   
   private final var level         = 0
   private final var newName       = 0
   private final var namesByNode   = [X3DNode : String] ()
   private final var importedNames = [X3DNode : String] ()

   internal final func enterScope ()
   {
      if level == 0
      {
         newName = 0
      }

      level += 1
   }
   
   internal final func leaveScope ()
   {
      level -= 1

      guard level == 0 else { return }
      
      nodes         .removeAll ()
      namesByNode   .removeAll ()
      importedNames .removeAll ()
   }
   
   internal final func setImportedNodes (_ importedNodes : [String : X3DImportedNode])
   {
      //let index = self .importedNodes .object (forKey: executionContext)
   }
   
   internal final func setExportedNodes (_ exportedNodes : [String : X3DExportedNode])
   {
      //let index = self .exportedNodes .object (forKey: executionContext)
   }
   
   // Node handling
   
   private final var nodes      = Set <X3DBaseNode> ()
   private final var routeNodes = Set <X3DBaseNode> ()

   internal final func isSharedNode (_ node : X3DNode) -> Bool
   {
      return false
   }

   internal final func addNode (_ node : X3DNode)
   {
      nodes .insert (node)
      
      addRouteNode (node)
   }
   
   internal final func existsNode (_ node : X3DBaseNode) -> Bool
   {
      return nodes .contains (node)
   }
   
   internal final func addImportedNode (_ exportedNode : X3DNode, _ importedName : String)
   {
      importedNames [exportedNode] = importedName
   }
   
   internal final func addRouteNode (_ routeNode : X3DBaseNode)
   {
      routeNodes .insert (routeNode)
   }
   
   internal final func existsRouteNode (_ routeNode : X3DBaseNode) -> Bool
   {
      return routeNodes .contains (routeNode)
   }
   
   // Name handling
   
   internal final func getName (_ node : X3DNode) -> String
   {
      // Is the node already in index?

      if let name = namesByNode [node]
      {
         return name
      }

      let index = names .object (forKey: executionContext)!

      // The node has no name.

      if node .getName () .isEmpty
      {
         if needsName (node)
         {
            let name = uniqueName ()

            index .add (NSString (utf8String: name))
            
            namesByNode [node] = name

            return name
         }

         // The node doesn't needs a name.

         return ""
      }

      // The node has a name.

      var name = node .getDisplayName ()
      
      if name .isEmpty
      {
         if needsName (node)
         {
            name = uniqueName ()
         }
         else
         {
            return ""
         }
      }
      else
      {
         name = uniqueName (name)
      }

      index .add (NSString (utf8String: name))
      
      namesByNode [node] = name

      return name
   }
   
   private final func needsName (_ node : X3DNode) -> Bool
   {
      if node .cloneCount > 1
      {
         return true
      }

      if node .hasRoutes
      {
         return true
      }

      let executionContext = node .executionContext!
      
      do
      {
         if let index = importedNodes .object (forKey: executionContext)
         {
            if index .contains (node)
            {
               return true
            }
         }
      }

      do
      {
         if let index = exportedNodes .object (forKey: executionContext)
         {
            if index .contains (node)
            {
               return true
            }
         }
      }

      return false;
   }
   
   private final func uniqueName () -> String
   {
      let index = names .object (forKey: executionContext)!
      
      newName += 1
      
      var name = "_\(newName)"

      while index .contains (NSString (utf8String: name))
      {
         newName += 1
         name     = "_\(newName)"
      }

      return name
   }
   
   private final func uniqueName (_ name : String) -> String
   {
      let index   = names .object (forKey: executionContext)!
      var newName = name
      var i       = 0

      while index .contains (NSString (utf8String: newName))
      {
         i += 1
         
         newName = "\(name)_\(i)"
      }

      return newName
   }
   
   internal final func getLocalName (_ node : X3DNode?) -> String?
   {
      guard let node = node else { return nil }
      
      if let importedName = importedNames [node]
      {
         return importedName
      }

      if existsNode (node)
      {
         return getName (node)
      }

      return nil
   }

   // Number formats
   
   public final var doublePrecision : Int = 16
   {
      didSet { doubleFormat = "%.\(abs (doublePrecision))g" }
   }
   
   public final var floatPrecision : Int = 5
   {
      didSet { floatFormat = "%.\(abs (floatPrecision))g" }
   }
   
   internal private(set) var doubleFormat = "%.16g"
   internal private(set) var floatFormat  = "%.5g"

   // Unit handling
   
   internal final var units : Bool = false
   
   internal func toUnit (_ unit : X3DUnitCategory, value : Double) -> Double
   {
      if units
      {
         return executionContext .toUnit (unit, value: value)
      }
      else
      {
         return value
      }
   }
   
   internal func toUnit (_ unit : X3DUnitCategory, value : Float) -> Float
   {
      if units
      {
         return executionContext .toUnit (unit, value: value)
      }
      else
      {
         return value
      }
   }
}
