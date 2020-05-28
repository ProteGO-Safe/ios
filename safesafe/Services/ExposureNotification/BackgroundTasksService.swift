//
//  BackgroundTasksService.swift
//  safesafe
//
//  Created by Rafał Małczyński on 13/05/2020.
//

import BackgroundTasks

protocol BackgroundTasksServiceProtocol {
    
    func scheduleExposureTask()
    
}

@available(iOS 13.5, *)
final class BackgroundTasksService: BackgroundTasksServiceProtocol {
    
    // MARK: - Properties
    
    private let backgroundTaskID = "pl.gov.mc.protegosafe.backgroundAnalysis.exposure-notification"
    private let exposureService: ExposureServiceProtocol
    
    // MARK: - Life Cycle
    
    init(exposureService: ExposureServiceProtocol) {
        self.exposureService = exposureService
        registerExposureTask()
    }
    
    // MARK: - Public methods
    
    func scheduleExposureTask() {
        guard exposureService.isExposureNotificationAuthorized else {
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
                console("Task timed out", type: .warning)
            }
            
            self?.exposureService
                .detectExposures()
                .done { exposures in
                    task.setTaskCompleted(success: true)
                }.catch {
                    console($0)
                    task.setTaskCompleted(success: true)
                }.finally {
                    self?.scheduleExposureTask()
                }
        }
    }
    
}
