//
//  Math.swift
//  X3D
//
//  Created by Holger Seelig on 15.09.20.
//  Copyright © 2020 Holger Seelig. All rights reserved.
//

/// Convert `value` from degrees to radians.
public func radians <Type : FloatingPoint> (_ value : Type) -> Type
{
   return value * Type .pi / Type (180)
}

/// Convert `value` from radians to degrees.
public func degrees <Type : FloatingPoint> (_ value : Type) -> Type
{
   return value * Type (180) / .pi
}

/// Returns the input value clamped to the lower and upper limits.
public func clamp <T : Comparable> (_ x: T, min: T, max: T) -> T
{
   return Swift .min (Swift .max (x, min), max)
}

/// Returns the fractional part of `value`.
public func fract (_ value : Double) -> Double
{
   var integer : Double = 0
   
   return modf (value, &integer)
}

///  Wrap value in the interval (low; high] so low <= result < high.
public func interval <Type : FloatingPoint> (_ value : Type, low : Type, high : Type) -> Type
{
   if value >= high
   {
      return fmod ((value - low), high - low) + low
   }

   if value < low
   {
      return fmod ((value - high), high - low) + high
   }

   return value
}

extension Int
{
   internal var isEven : Bool { self & 1 == 0 }
   internal var isOdd  : Bool { self & 1 == 1 }
}

extension Int32
{
   internal var isEven : Bool { self & 1 == 0 }
   internal var isOdd  : Bool { self & 1 == 1 }
}
