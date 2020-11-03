//
//  X3DFontStyleNode.swift
//  X3D
//
//  Created by Holger Seelig on 10.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

public class X3DFontStyleNode :
   X3DNode
{
   // Fields

   @SFString public final var language    : String = ""
   @MFString public final var family      : MFString .Value = ["SERIF"]
   @SFString public final var style       : String = "PLAIN"
   @SFFloat  public final var spacing     : Float = 1
   @SFBool   public final var horizontal  : Bool = true
   @SFBool   public final var leftToRight : Bool = true
   @SFBool   public final var topToBottom : Bool = true
   @MFString public final var justify     : MFString .Value = ["BEGIN"]

   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DFontStyleNode)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $style       .addInterest (X3DFontStyleNode .set_style,   self)
      $horizontal  .addInterest (X3DFontStyleNode .set_justify, self)
      $leftToRight .addInterest (X3DFontStyleNode .set_justify, self)
      $topToBottom .addInterest (X3DFontStyleNode .set_justify, self)
      $justify     .addInterest (X3DFontStyleNode .set_justify, self)

      set_style ()
      set_justify ()
   }
   
   // Member access
   
   internal func makeTextGeometry (textNode : Text) -> X3DTextGeometry? { nil }
   
   internal var scale : Float = 1
   
   enum Alignment
   {
      case FIRST
      case BEGIN
      case MIDDLE
      case END
   }
   
   internal private(set) final var normalizedMajorAlignment : Alignment = .BEGIN
   internal private(set) final var normalizedMinorAlignment : Alignment = .FIRST

   // Event handlers
   
   private final func set_style ()
   {
      requestImmediateLoad ()
   }
   
   private final func set_justify ()
   {
      let majorNormal = horizontal ? leftToRight : topToBottom

      normalizedMajorAlignment = justify .count > 0
                                 ? getAlignment (index: 0, normal: majorNormal)
                                 : majorNormal ? .BEGIN : .END

      let minorNormal = horizontal ? topToBottom : leftToRight

      normalizedMinorAlignment = justify .count > 1
                                 ? getAlignment (index: 1, normal: minorNormal)
                                 : minorNormal ? .FIRST : .END
   }
   
   private final func getAlignment (index : Int, normal : Bool) -> Alignment
   {
      if normal
      {
         // Return for west-european normal alignment.

         switch justify [index]
         {
            case "FIRST":  return .FIRST
            case "BEGIN":  return .BEGIN
            case "MIDDLE": return .MIDDLE
            case "END":    return .END
            default: break
         }
      }
      else
      {
         // Return appropriate alignment if topToBottom or leftToRight are FALSE.

         switch justify [index]
         {
            case "FIRST":  return .END
            case "BEGIN":  return .END
            case "MIDDLE": return .MIDDLE
            case "END":    return .BEGIN
            default: break
         }
      }
      
      return index > 0 ? .FIRST : .BEGIN
   }
   
   private final func makeFont (from URL: URL, size: CGFloat) throws -> CTFont
   {
      guard let dataProvider = CGDataProvider (url: URL as CFURL) else
      {
         throw NSError (domain: "File not found.", code: 77, userInfo: ["URL" : URL .absoluteURL .description])
      }
      
      guard let graphicsFont = CGFont (dataProvider) else
      {
         throw NSError (domain: "Not a font file.", code: 77, userInfo: ["URL" : URL .absoluteURL .description])
      }
      
      return CTFontCreateWithGraphicsFont (graphicsFont, size, nil, nil)
   }

   //
   
   private final func requestImmediateLoad ()
   {
      
   }
}
