//
// Metaheuristic.swift
// Metaheu
//
// Copyright (C) 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

/// A superclass for Metaheuristic algorithms. Subclasses should set up their initial
/// state in their init method and override the provided open functions appropriately.
open class Metaheuristic<T> {
	public typealias Result = T
	public typealias Guess = [T]
	public typealias OptimizeFunction = (Guess) -> Result

	// For nextGaussian()
	private var nextNextGaussian: Double? = {
		srand48(Int(arc4random()))
		return nil
	}()

	/// Run a metaheuristic algorithm to optimize a function of the form:
	/// y = f(X) where X = {x1, x2, ...}
	/// The initialGuess is an array of the initial guess of the values x1, x2, etc.
	/// The function is an implementation of the mathematical function to optimise.
	/// Returns the optimal result found for 'y', and the associated array 'X'.
	public func run(initialGuess: Guess, function: OptimizeFunction) -> (result: Result, solution: Guess) {

		// Initial run
		var bestSolution: Guess = initialGuess
		var bestResult: Result = function(bestSolution)

		// Repeats
		while shouldStep() {
			step()
			let newGuess = nextGuess(fromPreviousBestGuess: bestSolution)
			let result = function(newGuess)
			if accept(newResult: result, previousResult: bestResult) {
				bestResult = result
				bestSolution = newGuess
			}
		}

		return (bestResult, bestSolution)
	}

	/// The metaheuristic algorithm will continue to step forward, determine the next
	/// guess, compute the optimization function and determine the best result while
	/// this function returns true. This function is first called immediately after
	/// the function calculation with the initial guess.
	open func shouldStep() -> Bool {
		return false
	}

	/// Calculate the next step of the metaheuristic algorithm. Called immediately
	/// after shouldStop() if it returns false.
	open func step() { }

	/// Given the last guess, return the next guess. Called immediately after the
	/// step() function. The optimization function will be calculated with the new
	/// guess immediately after this function returns.
	open func nextGuess(fromPreviousBestGuess oldGuess: Guess) -> Guess {
		return []
	}

	/// Called immediately after a calculation of the optimization function (except
	/// after the calculation with the initial guess which is automatically accepted).
	/// Given the (new) result of the optimization function, should return true if
	/// this most recent result is prefered to the previous best result.
	open func accept(newResult: Result, previousResult: Result) -> Bool {
		return false
	}

	/// An implementation of Java's Random.nextGaussian(). Returns a pseudorandom,
	/// Gaussian ("normally") distributed Double value with a mean of 0.0 and standard
	/// deviation of 1.0.
	internal final func randomGaussian() -> Double {
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

	/// Returns a random Double from a uniform distribution between 0.0 and 1.0.
	internal final func randomDouble() -> Double {
		return Double(arc4random())
	}
}
