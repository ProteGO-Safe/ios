//
//  BackgroundTasksService.swift
//  safesafe
//
//  Created by Rafał Małczyński on 13/05/2020.
//

import BackgroundTasks
import UIKit.UIDevice
import PromiseKit

protocol BackgroundTasksServiceProtocol {
    
    func scheduleExposureTask()
    
}

@available(iOS 13.5, *)
final class BackgroundTasksService: BackgroundTasksServiceProtocol {
    
    // MARK: - Properties
    
    private let backgroundTaskID = Bundle.main.bundleIdentifier! + ".backgroundAnalysis.exposure-notification"
    private let exposureService: ExposureServiceProtocol
    private let districtsService: DistrictService
    
    // MARK: - Life Cycle
    
    init(exposureService: ExposureServiceProtocol, districtsService: DistrictService) {
        self.exposureService = exposureService
        self.districtsService = districtsService
    }
    
    // MARK: - Public methods
    
    func scheduleExposureTask() {
        guard UIDevice.current.model == "iPhone" else {  return }
        
        let taskRequest = BGProcessingTaskRequest(identifier: backgroundTaskID)
        taskRequest.requiresNetworkConnectivity = true
        
        do {
            try BGTaskScheduler.shared.submit(taskRequest)
        } catch {
            console("Failed to schedule BG task: \(error)", type: .error)
        }
    }
    
    // MARK: - Private methods
    
    func registerExposureTask() {
        console("📗 register time \(Date())")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskID, using: .main) { [weak self] task in
            console("🐝 Start BG task")
            guard let self = self else {
                console("😢 self is nil")
                task.setTaskCompleted(success: true)
                return
            }
            
            guard self.exposureService.isExposureNotificationAuthorized == true else {
                self.districtsService
                    .perform()
                    .done { response in
                        console("🗺 Fetch districts completed (guard) - changes in observed: \(response.changedObserved.count)")
                        guard let timestamp = response.changedObserved.first?.updatedAt else { return }
                        
                        NotificationManager.shared.showDistrictStatusLocalNotification(
                            with: "DISTRICT_STATUS_CHANGE_NOTIFICATION_MESSAGE (\(response.changedObserved.count))",
                            timestamp: timestamp
                        )
                }
                .ensure {
                    task.setTaskCompleted(success: true)
                }
                .catch { console($0, type: .error) }
                return
            }
            
            task.expirationHandler = {
                console("Task timed out", type: .warning)
            }
            
            when(resolved:
                self.exposureService.detectExposures().asVoid(),
                 self.districtsService.perform()
                    .done({ response in
                        console("🗺 Fetch districts completed - changes in observed: \(response.changedObserved.count)")
                        guard let timestamp = response.changedObserved.first?.updatedAt else { return }
                        
                        NotificationManager.shared.showDistrictStatusLocalNotification(
                            with: "DISTRICT_STATUS_CHANGE_NOTIFICATION_MESSAGE (\(response.changedObserved.count))",
                            timestamp: timestamp
                        )
                    })
                    .asVoid())
                .done { _ in
                    task.setTaskCompleted(success: true)
                }.catch {
                    console($0)
                    task.setTaskCompleted(success: true)
                }.finally {
                    self.scheduleExposureTask()
                }

        }
    }
}
