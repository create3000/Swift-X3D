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
   @MFString public final var family      : [String] = ["SERIF"]
   @SFString public final var style       : String = "PLAIN"
   @SFFloat  public final var spacing     : Float = 1
   @SFBool   public final var horizontal  : Bool = true
   @SFBool   public final var leftToRight : Bool = true
   @SFBool   public final var topToBottom : Bool = true
   @MFString public final var justify     : [String] = ["BEGIN"]
   
   // Properties
   
   @SFEnum public final var loadState : X3DLoadState = .NOT_STARTED_STATE
   
   internal var scale                                       : Float { 1 }
   internal private(set) final var normalizedMajorAlignment : Alignment = .BEGIN
   internal private(set) final var normalizedMinorAlignment : Alignment = .FIRST
   internal private(set) final var font                     : CTFont? = nil
   internal private(set) final var fileURL                  : URL?

   // Member types
   
   enum Alignment
   {
      case FIRST
      case BEGIN
      case MIDDLE
      case END
   }
   
   // Construction
   
   internal override init (_ browser : X3DBrowser, _ executionContext : X3DExecutionContext?)
   {
      super .init (browser, executionContext)

      types .append (.X3DFontStyleNode)
      
      addChildObjects ($loadState)
   }
   
   internal final override func initialize ()
   {
      super .initialize ()
      
      $family      .addInterest (X3DFontStyleNode .set_family,  self)
      $style       .addInterest (X3DFontStyleNode .set_style,   self)
      $horizontal  .addInterest (X3DFontStyleNode .set_justify, self)
      $leftToRight .addInterest (X3DFontStyleNode .set_justify, self)
      $topToBottom .addInterest (X3DFontStyleNode .set_justify, self)
      $justify     .addInterest (X3DFontStyleNode .set_justify, self)

      set_style ()
      set_justify ()
   }

   // Event handlers
   
   private final func set_family ()
   {
      guard checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.NOT_STARTED_STATE)

      requestImmediateLoad ()
   }

   private final func set_style ()
   {
      guard checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.NOT_STARTED_STATE)

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
   
   // Member access
   
   internal func makeTextGeometry (textNode : Text) -> X3DTextGeometry? { nil }

   private final func makeFont (from URL: URL) throws -> CTFont
   {
      let data = try Data (contentsOf: URL)
      
      guard let dataProvider = CGDataProvider (data: data as CFData) else
      {
         throw NSError (domain: "Couldn't read font data.", code: 77, userInfo: ["URL" : URL .absoluteURL .description])
      }
      
      guard let graphicsFont = CGFont (dataProvider) else
      {
         throw NSError (domain: "Not a font file.", code: 77, userInfo: ["URL" : URL .absoluteURL .description])
      }
      
      return CTFontCreateWithGraphicsFont (graphicsFont, 1, nil, nil)
   }

   static private let defaultFonts : [String : [String : URL]] =
   [
      "SERIF" : [
         "PLAIN" :      Bundle .module .url (forResource: "Fonts/DroidSerif-Regular",    withExtension: "ttf")!,
         "ITALIC" :     Bundle .module .url (forResource: "Fonts/DroidSerif-Italic",     withExtension: "ttf")!,
         "BOLD" :       Bundle .module .url (forResource: "Fonts/DroidSerif-Bold",       withExtension: "ttf")!,
         "BOLDITALIC" : Bundle .module .url (forResource: "Fonts/DroidSerif-BoldItalic", withExtension: "ttf")!,
      ],
      "SANS" : [
         "PLAIN" :      Bundle .module .url (forResource: "Fonts/Ubuntu-R",  withExtension: "ttf")!,
         "ITALIC" :     Bundle .module .url (forResource: "Fonts/Ubuntu-RI", withExtension: "ttf")!,
         "BOLD" :       Bundle .module .url (forResource: "Fonts/Ubuntu-B",  withExtension: "ttf")!,
         "BOLDITALIC" : Bundle .module .url (forResource: "Fonts/Ubuntu-BI", withExtension: "ttf")!,
      ],
      "TYPEWRITER" : [
         "PLAIN" :      Bundle .module .url (forResource: "Fonts/UbuntuMono-R",  withExtension: "ttf")!,
         "ITALIC" :     Bundle .module .url (forResource: "Fonts/UbuntuMono-RI", withExtension: "ttf")!,
         "BOLD" :       Bundle .module .url (forResource: "Fonts/UbuntuMono-B",  withExtension: "ttf")!,
         "BOLDITALIC" : Bundle .module .url (forResource: "Fonts/UbuntuMono-BI", withExtension: "ttf")!,
      ],
   ]
   
   // Load state handling
   
   internal func setLoadState (_ value : X3DLoadState)
   {
      guard value != loadState else { return }
      
      loadState = value
   }
   
   public var checkLoadState : X3DLoadState { loadState }

   // Load
   
   private final func requestImmediateLoad ()
   {
      guard checkLoadState != .COMPLETE_STATE && checkLoadState != .IN_PROGRESS_STATE else { return }
      
      setLoadState (.IN_PROGRESS_STATE)

      // Start load.

      let url : [(URL: URL?, custom: Bool)] = self .family .map
      {
         if let defaultFonts = X3DFontStyleNode .defaultFonts [$0], let defaultFont = defaultFonts [style] ?? defaultFonts ["PLAIN"]
         {
            return (defaultFont, false)
         }
         else
         {
            return (URL (string: $0, relativeTo: executionContext! .getWorldURL ()), true)
         }
      }
      .filter { $0 .URL != nil }
      
      let defaultFonts = X3DFontStyleNode .defaultFonts ["SERIF"]!
      let defaultFont  = defaultFonts [style] ?? defaultFonts ["PLAIN"]!
      
      browser! .fontQueue .async
      {
         guard let browser = self .browser else { return }
         
         for URL in url
         {
            do
            {
               let font = try self .makeFont (from: URL .URL!)

               DispatchQueue .main .async
               {
                  self .font    = font
                  self .fileURL = URL .URL! .absoluteURL
                  
                  self .setLoadState (.COMPLETE_STATE)
                  
                  if URL .custom
                  {
                     browser .console .info (t("Done loading font '%@'.", URL .URL! .absoluteURL .description))
                  }
               }
               
               return
            }
            catch
            {
               browser .console .warn (t("Invalid font. %@", error .localizedDescription))
               continue
            }
         }
         
         let font = try? self .makeFont (from: defaultFont)
         
         DispatchQueue .main .async
         {
            self .font    = font
            self .fileURL = defaultFont .absoluteURL
            
            self .setLoadState (.FAILED_STATE)
         }
      }
   }
}
