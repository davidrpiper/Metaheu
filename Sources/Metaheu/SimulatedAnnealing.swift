/**
 *  SimulatedAnnealing.swift
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

public class SimulatedAnnealing: Metaheuristic {
    public typealias Input = Double
    public typealias Result = Double
    
    /**
        The cooling (or annealing) schedule
     */
    public enum CoolingSchedule {
        /**
            T2 = alpha * T1
            Optimal alpha (0.7 ~ 0.95)
         */
        case Geometric(alpha: Double)
        
        /**
            T2 = T1 - beta
         */
        case Linear(beta: Double)
    }
    
    // Algorithm parameters
    private let T0: Double
    private let Tmin: Double
    private let maxRejects: UInt
    private let maxRuns: UInt
    private let maxAccepts: UInt
    private let k: Double
    private let minDiff: Double
    private let coolingSchedule: CoolingSchedule
    
    // Algorithm state
    private var runs: UInt
    private var accepts: UInt
    private var rejects: UInt
    private var t: Double
    private var totalEvaluations: UInt
    
    // Helpers
    private var globalBest: Solution = (result: .greatestFiniteMagnitude, guess: [])
    
    /// TODO: Docs
    public init(initialTemperature: Double = 1.0,
                minimumTemperature: Double = 1e-10,
                maxRejects: UInt = 2500,
                maxRuns: UInt = 500,
                maxAccepts: UInt = 15,
                minDiff: Double = 1e-8,
                coolingSchedule: CoolingSchedule = .Geometric(alpha: 0.95),
                k: Double = 1.0) {
        
        self.T0 = max(initialTemperature, 0)
        self.Tmin = max(minimumTemperature, 0)
        self.maxRejects = max(maxRejects, 0)
        self.maxRuns = max(maxRuns, 1)
        self.maxAccepts = max(maxAccepts, 1)
        self.k = k
        self.minDiff = minDiff
        self.coolingSchedule = coolingSchedule
        
        runs = 0
        accepts = 0
        rejects = 0
        t = T0
        totalEvaluations = 0
    }

    public func shouldContinue() -> Bool {
        return t > Tmin && rejects <= maxRejects
    }
    
    public func step() {
        runs += 1
        if (runs >= maxRuns || accepts >= maxAccepts) {
            
            // Cool according to schedule
            switch coolingSchedule {
            case let .Geometric(alpha):
                t = alpha * t
            case let .Linear(beta):
                t = t - beta
            }
            
            totalEvaluations += runs
            
            // Reset
            runs = 1
            accepts = 0
        }
    }
    
    public func generateNextGuess(fromPreviousBest guess: Guess) -> Guess {
        return guess.map { $0 + (Random.gaussian() * Random.double()) }
    }
    
    public func shouldAccept(newSolution: Solution, previousSolution: Solution) -> Bool {
        let deltaF = newSolution.result - previousSolution.result
        
        if -deltaF > minDiff {
            // Accept
            accepts += 1
            rejects = 0
            if newSolution.result < globalBest.result {
                globalBest = newSolution
            }
            return true
        }
        else if deltaF >= minDiff && exp(-deltaF/(k*t)) > Random.double() {
            // Maybe accept if worse
            accepts += 1
            return true
        }
        
        rejects += 1
        return false
    }
    
    public func willTerminate(withFinalSolution solution: Solution) -> Solution? {
        return globalBest
    }
    
    public func statistics() -> [String:String] {
        
        // Get cooling schedule string
        let cs: String
        switch coolingSchedule {
        case let .Geometric(alpha):
            cs = "Geometric, alpha = \(alpha)"
        case let .Linear(beta):
            cs = "Linear, beta = \(beta)"
        }
        
        return [
            "Total evaluations": "\(totalEvaluations)",
            "Returned global best": "\(true)",
            "Initial temperature": "\(T0)",
            "Minimum temperature": "\(Tmin)",
            "Maximum rejects": "\(maxRejects)",
            "Maximum runs": "\(maxRuns)",
            "Maximum accepts": "\(maxAccepts)",
            "Minimum difference": "\(minDiff)",
            "Boltzmann constant (k)": "\(k)",
            "Cooling schedule": "\(cs)",
        ]
    }
}