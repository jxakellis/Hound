//
//  Completion.swift
//  Hound
//
//  Created by Jonathan Xakellis on 9/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// CompletionTracker helps manage the progress of multiple async API queries. It checks that these tasks were all successful in order to invoke successfulCompletionHandler or otherwise invokes failureCompletionHandler
final class CompletionTracker: NSObject {
    
    // MARK: - Main
    
    init(numberOfTasks: Int, successfulCompletionHandler: @escaping (() -> Void), failureCompletionHandler: @escaping (() -> Void)) {
        self.numberOfTasks = numberOfTasks
        self.successfulCompletionHandler = successfulCompletionHandler
        self.failureCompletionHandler = failureCompletionHandler
        super.init()
    }
    
    // MARK: - Properties
    
    /// Number of completions of current tasks
    private var numberOfCompletions: Int = 0
    
    /// Number of tasks that need to be successful in order to invoke successfulCompletionHandler
    private var numberOfTasks: Int
    
    /// Once a completion handler is invoked, we track it here so a completion handler isn't accidently invoked twice
    private var completionHandlerInvoked = false
    
    /// Completion handler invoked if all tasks successfully complete
    private var successfulCompletionHandler: (() -> Void)
    
    /// Completion handler invoked if one or more of the tasks failed
    private var failureCompletionHandler: (() -> Void)
    
    // MARK: - Functions
    
    /// Increments numberOfCompletions. If numberOfCompletions == numberOfTasks, then executes the successfulCompletionHandler
    func completedTask() {
        guard completionHandlerInvoked == false else {
            return
        }
        
        numberOfCompletions += 1
        
        guard numberOfCompletions == numberOfTasks else {
            return
        }
        
        completionHandlerInvoked = true
        successfulCompletionHandler()
    }
    
    /// Executes failureCompletionHandler
    func failedTask() {
        guard completionHandlerInvoked == false else {
            return
        }
        
        completionHandlerInvoked = true
        failureCompletionHandler()
    }
}
