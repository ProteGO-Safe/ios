Aplikacja ProteGO iOS

# Zależności

Aplikacja ProteGO wykorzystuje Carthage oraz Cocoapods do zarządzania zależnościami w projekcie. Lista zależnosci standardowo w plikach `Cartfile` i `Podfile`

## Carthage

W folderze `scripts` znajduje się skrypt `updateCarthage.sh` ułatwiający zaktualizowanie zależności obsługiwanych przez Carthage.

# Rodzaje środowisk

Aplikacja ProteGO posiada kilka środowisk pracy, które zostały opisane [tutaj](https://github.com/ProteGO-app/specs/blob/master/specs/app_versions.md)

# Teksty w aplikacji

Aplikacja posiada wsparcie wielu języków. W folderze `scripts` znajduje się skrypt pomocniczy `updateLocalization.sh` który automatycznie ściąga najnowsze teksty z Google Spreadsheet oraz generuje odpowiednie struktury pomocnicze za pomocą SwiftGen.
