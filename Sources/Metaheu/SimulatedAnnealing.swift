//
// SimulatedAnnealing.swift
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

public class SimulatedAnnealing: Metaheuristic<Double> {

	// Algorithm parameters
	private let T0: Double
	private let Tmin: Double
	private let maxRejects: UInt
	private let maxRuns: UInt
	private let maxAccepts: UInt
	private let k: Double
	private let alpha: Double
	private let minDiff: Double

	// Algorithm state
	private var runs: UInt
	private var accepts: UInt
	private var rejects: UInt
	private var totalEvaluations: UInt
	private var t: Double

	/// TODO: Docs
	public init(T0: Double = 1.0,
				Tmin: Double = 1e-10,
				maxRejects: UInt = 2500,
				maxRuns: UInt = 500,
				maxAccepts: UInt = 15,
				k: Double = 1.0,
				alpha: Double = 0.95, // optimal (0.7 ~ 0.95)
				minDiff: Double = 1e-8) {
		self.T0 = max(T0, 0)
		self.Tmin = max(Tmin, 0)
		self.maxRejects = max(maxRejects, 0)
		self.maxRuns = max(maxRuns, 1)
		self.maxAccepts = max(maxAccepts, 1)
		self.k = k
		self.alpha = alpha
		self.minDiff = minDiff
		runs = 0
		accepts = 0
		rejects = 0
		totalEvaluations = 0
		t = T0
	}

	override public func shouldStep() -> Bool {
		return t > Tmin && rejects <= maxRejects
	}

	override public func step() {
		runs += 1
		if (runs >= maxRuns || accepts >= maxAccepts) {

			// Cool according to schedule
			t = alpha * t;
			totalEvaluations += runs;

			// Reset
			runs = 1;
			accepts = 0;
		}
	}

	override public func nextGuess(fromPreviousBestGuess oldGuess: Guess) -> Guess {
		return oldGuess.map { $0 + (randomGaussian() * randomDouble()) }
	}

	override public func accept(newResult: Result, previousResult: Result) -> Bool {
		let deltaF = newResult - previousResult
		if -deltaF > minDiff {
			// Accept
			accepts += 1
			rejects = 0
			return true
		}
		else if deltaF >= minDiff && exp(-deltaF/(k*t)) > randomDouble() {
			// Maybe accept if worse
			accepts += 1
			return true
		}
		rejects += 1
		return false
	}
}
