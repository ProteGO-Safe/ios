//
//  BackgroundTasksService.swift
//  safesafe
//
//  Created by Rafał Małczyński on 13/05/2020.
//

import BackgroundTasks
import UserNotifications
import UIKit.UIDevice

protocol BackgroundTasksServiceProtocol {
    
    func scheduleExposureTask()
    
}

@available(iOS 13.5, *)
final class BackgroundTasksService: BackgroundTasksServiceProtocol {
    
    // MARK: - Properties
    
    private let backgroundTaskID = Bundle.main.bundleIdentifier! + ".backgroundAnalysis.exposure-notification"
    private let exposureService: ExposureServiceProtocol
    
    // MARK: - Life Cycle
    
    init(exposureService: ExposureServiceProtocol) {
        self.exposureService = exposureService
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
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskID, using: .main) { [weak self] task in
            guard self?.exposureService.isExposureNotificationAuthorized == true else {
                task.setTaskCompleted(success: true)
                return
            }
            task.expirationHandler = {
                #if STAGE
                self?.scheduleNotification(body: "Task timeout: \(Date().timeIntervalSince1970)")
                console("Task timed out", type: .warning)
                #endif
            }
            
            self?.exposureService
                .detectExposures()
                .done { exposures in
                    #if STAGE
                    self?.scheduleNotification(body: "Task success: \(Date().timeIntervalSince1970)\nexposures: \(exposures.count)")
                    #endif
                    task.setTaskCompleted(success: true)
                }.catch {
                    #if STAGE
                    self?.scheduleNotification(body: "Task failure: \(Date().timeIntervalSince1970)\nexerror: \($0.localizedDescription)")
                    #endif
                    console($0)
                    task.setTaskCompleted(success: true)
                }.finally {
                    self?.scheduleExposureTask()
                }
        }
    }
    
    func scheduleNotification(body: String) {

        //Compose New Notificaion
        let content = UNMutableNotificationContent()
        let categoryIdentifire = "Delete Notification Type"
        content.sound = UNNotificationSound.default
        content.body = body
        content.categoryIdentifier = categoryIdentifire

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}
