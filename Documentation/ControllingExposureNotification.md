# Controlling Exposure Notification

Enables users to start and stop broadcasting and scanning, indicate if exposure notifications are running.

- Start the Exposure Notification Framework broadcasting and scanning process.
  - PWA requests start of Exposure Notification Framework
  - Call **ExposureService.setExposureNotificationEnabled(_)** with `true`.
    - If not previously started, Exposure Notification Framework shows a user dialog for consent to start exposure detection and get permission.
  - If permission is granted and required services are enabled, Exposure Notification Framework will start broadcasting and scanning.
    - All of Exposure Notification Framework methods are now available.
    - Pass Exposure Notification Framework status - **ENABLED** - to PWA.
  - If user denies on any of Exposure Notification Framework requests, onboarding is skipped and Exposure Notification Framework disabled.
    - Pass Exposure Notification Framework status - **DISABLED** - to PWA.
  - If Exposure Notification Framework is not available on user's device
    - Pass Exposure Notification Framework status - **NOT_SUPPORTED** - to PWA.
  - If any of the required services is disabled during Exposure Notification Framework
    - Broadcasting and scanning process are stopped.
    - Pass services status to PWA to inform user that something is missing.
    - Exposure Notification Framework shows a user dialog to enable required service.
- Indicate if exposure notifications are enabled.
  - Call **ExposureService.isExposureNotificationEnabled**
- Disable broadcasting and scanning.
  -Call **ExposureService.setExposureNotificationEnabled(_)** with `false`
    - Contents of the Exposure Notification Framework database and keys will remain.
    - If the app has been uninstalled by the user, this will be automatically invoked and the database and keys will be wiped from the device.