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
    private let dashboardWorker: DashboardWorkerType
    
    // MARK: - Life Cycle
    
    init(
        exposureService: ExposureServiceProtocol,
        districtsService: DistrictService,
        dashboardWorker: DashboardWorkerType
    ) {
        self.exposureService = exposureService
        self.districtsService = districtsService
        self.dashboardWorker = dashboardWorker
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
            
            self.dashboardWorker.fetchData(shouldDelegateResult: true)
            
            guard self.exposureService.isExposureNotificationAuthorized == true else {
                self.districtsService
                    .perform()
                    .done { response in
                        console("🗺 Fetch districts completed (guard) - changes in observed: \(response.changedObserved.count)")
                        self.manageDistrictsNotification(response)
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
                        self.manageDistrictsNotification(response)
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
    
    private func manageDistrictsNotification(_ response: DistrictService.Response) {
        guard let timestamp = response.changedObserved.first?.updatedAt else { return }
        
        NotificationManager.shared.showDistrictStatusLocalNotification(
            with: response.allChanged,
            observed: response.observed,
            timestamp: timestamp,
            delay: 3
        )
    }
}
