//
//  Metaheuristic.swift
//  Metaheu
//
//  Created by David Piper on 6/4/17.
//

public protocol Metaheuristic {
    
    /// A type for the inputs of the optimisation function
    associatedtype Input
    
    /// A type for the result of the optimisation function
    associatedtype Result
    
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
    func generateNextGuessfromPreviousBest(guess: [Input]) -> [Input]
    
    /**
        Given the latest result of the optimization function, return true if this
        most result should be accepted over the previous best result.
     */
    func shouldAccept(newResult: Result, previousResult: Result) -> Bool
}

extension Metaheuristic {
    
    /**
        Run a metaheuristic algorithm to optimize a function of the form:
        y = f(X) where X = {x1, x2, ...}
        The initialGuess is an array of the initial guess of the values x1, x2, etc.
        The function is an implementation of the mathematical function to optimise.
        Returns the optimal result found for 'y', and the associated array 'X'.
     */
    public func run(initialGuess: [Input], function: ([Input]) -> Result) -> (result: Result, solution: [Input]) {
        
        // Initial run
        var bestSolution: [Input] = initialGuess
        var bestResult: Result = function(bestSolution)
        
        // Repeats
        while shouldContinue() {
            step()
            let newGuess = generateNextGuessfromPreviousBest(guess: bestSolution)
            let result = function(newGuess)
            if shouldAccept(newResult: result, previousResult: bestResult) {
                bestResult = result
                bestSolution = newGuess
            }
        }
        
        return (bestResult, bestSolution)
    }
}
