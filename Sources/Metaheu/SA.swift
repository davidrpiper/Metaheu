//
//  SimulatedAnnealing.swift
//  Metaheu
//
//  Created by David Piper on 6/4/17.
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public class SimulatedAnnealing: Metaheuristic {
    
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

    public func shouldContinue() -> Bool {
        return t > Tmin && rejects <= maxRejects
    }
    
    public func step() {
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
    
    public func generateNextGuessfromPreviousBest(guess: [Double]) -> [Double] {
        return guess.map { $0 + (Random.randomGaussian() * Random.randomDouble()) }
    }
    
    public func shouldAccept(newResult: Double, previousResult: Double) -> Bool {
        let deltaF = newResult - previousResult
        if -deltaF > minDiff {
            // Accept
            accepts += 1
            rejects = 0
            return true
        }
        else if deltaF >= minDiff && exp(-deltaF/(k*t)) > Random.randomDouble() {
            // Maybe accept if worse
            accepts += 1
            return true
        }
        rejects += 1
        return false
    }
    
}
