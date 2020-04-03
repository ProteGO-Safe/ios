import Foundation

protocol Scanner {
    /// Sets scanner mode, which controls scanning on/off state.
    /// - Parameter mode: Scanner mode
    func setMode(_ mode: ScannerMode)

    /// Returns scanner mode
    func getMode() -> ScannerMode

    /// Returns true if scanner is using the radio.
    func isScanning() -> Bool
}
