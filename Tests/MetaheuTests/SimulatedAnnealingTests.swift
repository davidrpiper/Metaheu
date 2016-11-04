//
// SimulatedAnnealingTests.swift
// Metaheu
//
// Copyright (C) 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

import XCTest
@testable import Metaheu

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

class SimulatedAnnealingTests: XCTestCase {

	let banana: ([Double]) -> Double = {
		return pow((1 - $0[0]), 2) + 100 * pow(($0[1] - pow($0[0], 2)), 2);
	}

	func testNoParams() {
		let initialGuess: [Double] = [1.1, 1.1]
		let sa = SimulatedAnnealing()
		let (result, solution) = sa.run(initialGuess: initialGuess, function: banana)

		XCTAssertEqual(solution.count, 2)
		XCTAssertEqualWithAccuracy(solution[0], 1.0, accuracy: 0.25)
		XCTAssertEqualWithAccuracy(solution[1], 1.0, accuracy: 0.25)
		XCTAssertEqualWithAccuracy(result, 0.0, accuracy: 2.0)
		XCTAssertGreaterThanOrEqual(result, 0.0)
	}

	func testParams() {
		let initialGuess: [Double] = [1.1, 1.1]
		let sa = SimulatedAnnealing(T0: 1.0, Tmin: 1e-10,
		                            maxRejects: 2500, maxRuns: 500, maxAccepts: 15,
		                            k: 1.0, alpha: 0.95, minDiff: 1e-8)
		let (result, solution) = sa.run(initialGuess: initialGuess, function: banana)

		XCTAssertEqual(solution.count, 2)
		XCTAssertEqualWithAccuracy(solution[0], 1.0, accuracy: 0.25)
		XCTAssertEqualWithAccuracy(solution[1], 1.0, accuracy: 0.25)
		XCTAssertEqualWithAccuracy(result, 0.0, accuracy: 2.0)
		XCTAssertGreaterThanOrEqual(result, 0.0)
	}

}
