# Reporting Risk Level

Pass the highest risk level of user's exposure from last 14 days detected by Exposure Notification Framework to PWA.

Steps:

- PWA request reporting risk level
  - Service method: [JSBridge.onBridgeData(type:body:completion:)](../safesafe/Services/JavaScript Bridge/JSBridge.swift)
  - Data Type: [JSBridge.BridgeDataType.exposureList](../safesafe/Services/JavaScript Bridge/JSBridge.swift)
- Get all data about exposures from local database
  - Service method: [ExposureSummaryService.getExposureSummary()](../safesafe/Services/ExposureNotification/ExposureSummaryService.swift)
- Calc risk level from risk score (max **riskScore** = 4096):
  - Used model: [ExposureSummary](../safesafe/Services/ExposureNotification/Models/ExposureSummary.swift)
- Pass calculated risk level to PWA by returning json with result model back through JSBridge
  - Service method: [JSBridge.exposureListGetBridgeDataResponse(requestID:)](../safesafe/Services/JavaScript Bridge/JSBridge.swift)