# Downloading Diagnosis Keys

A regularly scheduled background task is executed to download files with batch of Temporary Exposure Keys (**TEK**) of positively diagnosed, called Diagnosis Keys files. Each of the batch file has unique timestamp. The timestamp that identifying when a certain Diagnosis Keys file was created is used to select only not yet analyzed files for download.

Steps:
- The app gets a list of available Diagnosis Keys (`index.txt`) files from CDN:
  - Moya Target endpoint: [`case get`](../safesafe/Networking/ExposureKeysTarget.swift)
  - Service function: [`DiagnosisKeysDownloadServiceProtocol.download() -> Promise<[URL]>`](../safesafe/Services/ExposureNotification/DiagnosisKeysDownloadService.swift)
- Only files with the timestamp older than the latest successfully provided to analyze batch are selected for download
- Files are downloaded over HTTPS protocol to internal device storage
  - Moya Target endpoint: [`case download(fileName: String, destination: DownloadDestination)`](../safesafe/Networking/ExposureKeysTarget.swift)
  - Service function: [`DiagnosisKeysDownloadService.downloadFiles(withNames names: [String], keysDirectoryURL: URL) -> Promise<[URL]>`](../safesafe/Services/ExposureNotification/DiagnosisKeysDownloadService.swift)
- Downloaded zip archives are decompressed to provide flat array of URL pairs: 
  - `export.bin` - the binary containing Diagnosis Keys
  - `export.sig` - the raw signature and information needed for verification
