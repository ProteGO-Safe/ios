//
//  BackgroundTasksManager.swift
//  safesafe
//
//  Created by Rafał Małczyński on 13/05/2020.
//

import BackgroundTasks

protocol BackgroundTasksManagerProtocol {
    
    func scheduleExposureTask()
    
}

final class BackgroundTasksManager: BackgroundTasksManagerProtocol {
    
    // MARK: - Properties
    
    private let backgroundTaskID = "protego.safe.backgroundTask.exposure-notification"
    private let exposureManager: ExposureManagerProtocol
    
    // MARK: - Life Cycle
    
    init(exposureManager: ExposureManagerProtocol) {
        self.exposureManager = exposureManager
        registerExposureTask()
    }
    
    // MARK: - Public methods
    
    func scheduleExposureTask() {
        guard exposureManager.isExposureNotificationAuthorized else {
            return
        }
        
        let taskRequest = BGProcessingTaskRequest(identifier: backgroundTaskID)
        taskRequest.requiresNetworkConnectivity = true
        
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            console("Failed to schedule BG task: \(error)", type: .error)
        }
    }
    
    // MARK: - Private methods
    
    private func registerExposureTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskID, using: .main) { [weak self] task in
            task.expirationHandler = {
                // Print some error? This closure may be caused by timed-out background operation
            }
            
            self?.exposureManager.detectExposures { result in
                switch result {
                case .success:
                    task.setTaskCompleted(success: true)
                    
                case .failure:
                    task.setTaskCompleted(success: false)
                    // Again - opportunity to do some error handling. E.g. when user kills EN permissions while task has already been scheduled maybe we could show some popup?
                }
            }
            
            self?.scheduleExposureTask()
        }
    }
    
}
