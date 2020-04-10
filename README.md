![CI](https://github.com/ProteGO-app/ios/workflows/CI/badge.svg)

# Aplikacja ProteGO dla iOS

## Zależności

Aplikacja ProteGO wykorzystuje Carthage oraz CocoaPods do zarządzania zależnościami w projekcie. Lista zależnosci standardowo w plikach `Cartfile` i `Podfile`

### Początkowa konfiguracja projektu

 * Instalacja Gem-ów Ruby (w tym CocoaPods): `bundle install`
 * Instalacja Carthage: [jest kilka możliwych opcji](https://github.com/Carthage/Carthage#installing-carthage)
 * Akualizacja zależności zarządzanych przez Carthage: `./scripts/updateCarthage.sh`

## Rodzaje środowisk

Aplikacja ProteGO posiada kilka środowisk pracy, które zostały opisane [tutaj](https://github.com/ProteGO-app/specs/blob/master/specs/app_versions.md)

## Teksty w aplikacji

Aplikacja posiada wsparcie wielu języków. W folderze `scripts` znajduje się skrypt pomocniczy `updateLocalization.sh` który automatycznie ściąga najnowsze teksty z Google Spreadsheet oraz generuje odpowiednie struktury pomocnicze za pomocą SwiftGen.
