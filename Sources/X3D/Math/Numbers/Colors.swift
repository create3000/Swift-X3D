//
//  Color.swift
//  X3D
//
//  Created by Holger Seelig on 05.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

import simd

public typealias Color3d = simd_double3
public typealias Color3f = simd_float3
public typealias Color4d = simd_double4
public typealias Color4f = simd_float4

// Extensions

extension Color3d
{
   @inlinable public var r : Double { get  { x } set { x = X3D .clamp (newValue, min: 0, max: 1) } }
   @inlinable public var g : Double { get  { y } set { y = X3D .clamp (newValue, min: 0, max: 1) } }
   @inlinable public var b : Double { get  { z } set { z = X3D .clamp (newValue, min: 0, max: 1) } }
}

extension Color3f
{
   @inlinable public var r : Float { get  { x } set { x = X3D .clamp (newValue, min: 0, max: 1) } }
   @inlinable public var g : Float { get  { y } set { y = X3D .clamp (newValue, min: 0, max: 1) } }
   @inlinable public var b : Float { get  { z } set { z = X3D .clamp (newValue, min: 0, max: 1) } }
}

extension Color4d
{
   @inlinable public var r : Double { get  { x } set { x = X3D .clamp (newValue, min: 0, max: 1) } }
   @inlinable public var g : Double { get  { y } set { y = X3D .clamp (newValue, min: 0, max: 1) } }
   @inlinable public var b : Double { get  { z } set { z = X3D .clamp (newValue, min: 0, max: 1) } }
   @inlinable public var a : Double { get  { w } set { w = X3D .clamp (newValue, min: 0, max: 1) } }
}

extension Color4f
{
   @inlinable public var r : Float { get  { x } set { x = X3D .clamp (newValue, min: 0, max: 1) } }
   @inlinable public var g : Float { get  { y } set { y = X3D .clamp (newValue, min: 0, max: 1) } }
   @inlinable public var b : Float { get  { z } set { z = X3D .clamp (newValue, min: 0, max: 1) } }
   @inlinable public var a : Float { get  { w } set { w = X3D .clamp (newValue, min: 0, max: 1) } }
}

extension Color3f
{
   /// Returns the HSV representation of this RGB color.
   public var hsv : Color3f
   {
      var h : Float = 0
      var s : Float = 0
      var v : Float = 0

      let min = Swift .min (r, g, b)
      let max = Swift .max (r, g, b)

      v = max // v

      let delta = max - min

      if max != 0 && delta != 0
      {
         s = delta / max // s
      
         if r == max
         {
            h = (g - b) / delta // between yellow & magenta
         }
         else if g == max
         {
            h = 2 + (b - r) / delta // between cyan & yellow
         }
         else
         {
            h = 4 + (r - g) / delta // between magenta & cyan
         }
         
         h *= .pi / 3 // radians
      
         if h < 0
         {
            h += 2 * .pi
         }
      }
      else
      {
         // r = g = b = 0 // s = 0, h is undefined
         s = 0
         h = 0
      }

      return Color3f (h, s, v)
   }
   
   /// Returns the RGB representation of this HSV color.
   public var rgb : Color3f
   {
      let h : Float = self [0]
      var s : Float = self [1]
      var v : Float = self [2]

      // H is given on [0, 2 * Pi]. S and V are given on [0, 1].
      // RGB are each returned on [0, 1].

      v = X3D .clamp (v, min: 0, max: 1)

      if s == 0
      {
         // achromatic (grey)
         return Color3f (v, v, v)
      }

      s = X3D .clamp (s, min: 0, max: 1)

      let w = degrees (interval (h, low: 0, high: .pi * 2)) / 60 // sector 0 to 5

      let i = floor (w)
      let f = w - i // factorial part of h
      let p = v * (1 - s)
      let q = v * (1 - s * f)
      let t = v * (1 - s * (1 - f))

      switch i
      {
         case 0:  return Color3f (v, t, p)
         case 1:  return Color3f (q, v, p)
         case 2:  return Color3f (p, v, t)
         case 3:  return Color3f (p, q, v)
         case 4:  return Color3f (t, p, v)
         default: return Color3f (v, p, q)
      }
   }
}

extension Color4f
{
   /// Returns the HSVA representation of this RGBA color.
   public var hsva : Color4f
   {
      var h : Float = 0
      var s : Float = 0
      var v : Float = 0

      let min = Swift .min (r, g, b)
      let max = Swift .max (r, g, b)

      v = max // v

      let delta = max - min

      if max != 0 && delta != 0
      {
         s = delta / max // s
      
         if r == max
         {
            h = (g - b) / delta // between yellow & magenta
         }
         else if g == max
         {
            h = 2 + (b - r) / delta // between cyan & yellow
         }
         else
         {
            h = 4 + (r - g) / delta // between magenta & cyan
         }
         
         h *= .pi / 3 // radians
      
         if h < 0
         {
            h += 2 * .pi
         }
      }
      else
      {
         // r = g = b = 0 // s = 0, h is undefined
         s = 0
         h = 0
      }

      return Color4f (h, s, v, a)
   }
   
   /// Returns the RGBA representation of this HSVA color.
   public var rgba : Color4f
   {
      let h : Float = self [0]
      var s : Float = self [1]
      var v : Float = self [2]

      // H is given on [0, 2 * Pi]. S and V are given on [0, 1].
      // RGB are each returned on [0, 1].

      v = X3D .clamp (v, min: 0, max: 1)

      if s == 0
      {
         // achromatic (grey)
         return Color4f (v, v, v, a)
      }

      s = X3D .clamp (s, min: 0, max: 1)

      let w = degrees (interval (h, low: 0, high: .pi * 2)) / 60 // sector 0 to 5

      let i = floor (w)
      let f = w - i // factorial part of h
      let p = v * (1 - s)
      let q = v * (1 - s * f)
      let t = v * (1 - s * (1 - f))

      switch i
      {
         case 0:  return Color4f (v, t, p, a)
         case 1:  return Color4f (q, v, p, a)
         case 2:  return Color4f (p, v, t, a)
         case 3:  return Color4f (p, q, v, a)
         case 4:  return Color4f (t, p, v, a)
         default: return Color4f (v, p, q, a)
      }
   }
}

/// Circular linear interpolate from `source` color and to `destination` color in hsv space by an amout of `t`.
public func hsv_mix (_ source: Color3f, _ destination : Color3f, t : Float) -> Color3f
{
   let a  = source
   let b  = destination
   var ha = a [0]
   let sa = a [1]
   let va = a [2]
   var hb = b [0]
   let sb = b [1]
   let vb = b [2]

   if sa == 0
   {
      ha = hb
   }

   if sb == 0
   {
      hb = ha
   }

   let range = abs (hb - ha)

   if range <= .pi
   {
      return Color3f (simd_mix (ha, hb, t),
                      simd_mix (sa, sb, t),
                      simd_mix (va, vb, t))
   }
   else
   {
      let step = (.pi * 2 - range) * t
      var h    = ha < hb ? ha - step : ha + step

      if h < 0
      {
         h += .pi * 2
      }
      else if h > .pi * 2
      {
         h -= .pi * 2
      }

      return Color3f (h,
                      simd_mix (sa, sb, t),
                      simd_mix (va, vb, t))
   }
}

/// Circular linear interpolate from `source` color and to `destination` color in hsv space by an amout of `t`.
public func hsva_mix (_ source: Color4f, _ destination : Color4f, t : Float) -> Color4f
{
   let a  = source
   let b  = destination
   var ha = a [0]
   let sa = a [1]
   let va = a [2]
   let aa = a [3]
   var hb = b [0]
   let sb = b [1]
   let vb = b [2]
   let ab = b [3]

   if sa == 0
   {
      ha = hb
   }

   if sb == 0
   {
      hb = ha
   }

   let range = abs (hb - ha)

   if range <= .pi
   {
      return Color4f (simd_mix (ha, hb, t),
                      simd_mix (sa, sb, t),
                      simd_mix (va, vb, t),
                      simd_mix (aa, ab, t))
   }
   else
   {
      let step = (.pi * 2 - range) * t
      var h    = ha < hb ? ha - step : ha + step

      if h < 0
      {
         h += .pi * 2
      }
      else if h > .pi * 2
      {
         h -= .pi * 2
      }

      return Color4f (h,
                      simd_mix (sa, sb, t),
                      simd_mix (va, vb, t),
                      simd_mix (aa, ab, t))
   }
}
