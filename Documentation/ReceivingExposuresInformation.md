# Receiving Exposures Documentation

When Exposure Notification Framework finishes comparing diagnosis keys with keys stored on the device and it detects some exposures when **ExposureService.detectExposures()** is called, then result of this method will contain potential exposures. In order to provide user a correct risk level that is shown in the PWA module application has to get detailed information about detected exposures and save them to the local, encrypted database.

Steps:

- Start by detecting exposures.
    - Service method: [ExposureService.detectExposures()](../safesafe/Services/ExposureNotification/ExposureService.swift)
- The list of **Exposure** objects is provided, based on list of **ENExposureDetectionSummary** objects.
- The app saves every exposure information to **encrypted** database with **only** the following data:
  - Day level resolution that the exposure occurred
  - Length of exposure (value is stored in seconds)
  - The total risk score calculated for the exposure
    - Service method: [ExposureSummaryService.getExposureSummary()](../safesafe/Services/ExposureNotification/ExposureSummaryService.swift)