/**
 *  Random.swift
 *  Metaheu
 *
 *  Copyright (c) 2016 - 2017 David Piper, @_davidpiper
 *
 *  This software may be modified and distributed under the terms
 *  of the MIT license. See the LICENSE file for details.
 */

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public struct Random {
    
    // For randomGaussian()
    private static var nextNextGaussian: Double? = {
        srand48(Int(arc4random()))
        return nil
    }()
    
    /**
        Returns a pseudorandom, Double from a normal ("Gaussian") distribution with
        a mean of 0.0 and a standard deviation of 1.0.
        
        This is a Swift implementation of Java's Random.nextGaussian().
     */
    public static func gaussian() -> Double {
        if let gaussian = nextNextGaussian {
            nextNextGaussian = nil
            return gaussian
        } else {
            var v1, v2, s: Double
            repeat {
                v1 = 2 * drand48() - 1
                v2 = 2 * drand48() - 1
                s = v1 * v1 + v2 * v2
            } while s >= 1 || s == 0
            let multiplier = sqrt(-2 * log(s)/s)
            nextNextGaussian = v2 * multiplier
            return v1 * multiplier
        }
    }
    
    /**
        Returns a random Double from a uniform distribution between 0.0 and 1.0.
     */
    public static func double() -> Double {
        return Double(arc4random()) / Double(UInt32.max)
    }
}
