/**
 *  SimulatedAnnealingTest.swift
 *  Metaheu
 *
 *  Copyright (c) 2016 - 2017 David Piper, @_davidpiper
 *
 *  This software may be modified and distributed under the terms
 *  of the MIT license. See the LICENSE file for details.
 */

import XCTest
@testable import Metaheu

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

class SimulatedAnnealingTest: XCTestCase {

	let banana: ([Double]) -> Double = {
		return pow((1 - $0[0]), 2) + 100 * pow(($0[1] - pow($0[0], 2)), 2);
	}

	func testNoParams() {
		let initialGuess: [Double] = [1.1, 1.1]
		let sa = SimulatedAnnealing()
		let (result, solution) = sa.run(initialGuess: initialGuess, function: banana)

		XCTAssertEqual(solution.count, 2)
		XCTAssertEqualWithAccuracy(solution[0], 1.0, accuracy: 0.1)
		XCTAssertEqualWithAccuracy(solution[1], 1.0, accuracy: 0.1)
		XCTAssertEqualWithAccuracy(result, 0.0, accuracy: 1.0)
		XCTAssertGreaterThanOrEqual(result, 0.0)
	}
}
