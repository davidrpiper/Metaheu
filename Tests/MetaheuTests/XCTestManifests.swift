//
// XCTestManifests.swift
// Metaheu
//
// Copyright (C) 2016 David Piper, @_dpiper
//
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.
//

#if os(Linux)
	import XCTest
	public func allTests() -> [XCTestCaseEntry] {
		return [
			testCase(SimulatedAnnealingTests.allTests)
		]
	}
#endif
