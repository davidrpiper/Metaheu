/**
 *  Metaheuristic.swift
 *  Metaheu
 *
 *  Copyright (c) 2016 - 2017 David Piper, @_davidpiper
 *
 *  This software may be modified and distributed under the terms
 *  of the MIT license. See the LICENSE file for details.
 */

public protocol Metaheuristic {
    
    /// A type for the inputs of the optimisation function
    associatedtype Input
    
    /// A type for the result of the optimisation function
    associatedtype Result
    
    typealias Guess = [Input]
    typealias Solution = (result: Result, guess: Guess)
    
    /**
        The metaheuristic algorithm will continue to iterate while this function
        returns true. This function is first called immediately after the function
        calculation with the initial guess.
     */
    func shouldContinue() -> Bool
    
    /**
        Updates the state of the metaheuristic algorithm. Called immediately after
        shouldContinue() if it returns true.
     */
    func step()
    
    /**
        Generate the next guess given the previous best guess. Called after the
        step() function. The optimization function will be calculated with the
        new guess.
     */
    func generateNextGuess(fromPreviousBest guess: Guess) -> Guess
    
    /**
        Given the latest result of the optimization function, return true if this
        most result should be accepted over the previous best result.
     */
    func shouldAccept(newSolution: Solution, previousSolution: Solution) -> Bool
    
    /**
        Called immediately before the Metheurtic algorithm completes. Gives the
        algorithm a chance to return a different result from the one on which the
        algorithm completed. The most common use case is to return the best solution
        found across the whole algorithm (as the algorithm may terminate on a sub-
        optimal solution).
     
        Return nil if no override is necessary (the default if unimplemented).
     */
    func willTerminate(withFinalSolution solution: Solution) -> Solution?
}

extension Metaheuristic {
    
    /**
        Run a metaheuristic algorithm to optimize a function of the form:
        y = f(X) where X = {x1, x2, ...}
        The initialGuess is an array of the initial guess of the values x1, x2, etc.
        The function is an implementation of the mathematical function to optimise.
        Returns the optimal result found for 'y', and the associated array 'X'.
     */
    public func run(initialGuess: Guess, function: (Guess) -> Result) -> Solution {
        
        // Initial run
        var bestGuess: Guess = initialGuess
        var bestResult: Result = function(bestGuess)
        
        // Repeats
        while shouldContinue() {
            step()
            let newGuess = generateNextGuess(fromPreviousBest: bestGuess)
            let result = function(newGuess)
            
            if shouldAccept(newSolution: (result, newGuess),
                            previousSolution: (bestResult, bestGuess)) {
                bestResult = result
                bestGuess = newGuess
            }
        }
        
        // Check if we want to override the final guess (presumably with a more optimal one)
        if let override = willTerminate(withFinalSolution: (bestResult, bestGuess)) {
            return override
        }
        
        return (bestResult, bestGuess)
    }
    
    /**
        By default we do not override the final solution from the algorithm.
     */
    public func willTerminate(withFinalSolution solution: Solution) -> Solution? {
        return nil
    }
}
