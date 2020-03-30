Aplikacja ProteGO iOS

# Zależności

Aplikacja ProteGO wykorzystuje Carthage oraz Cocoapods do zarządzania zależnościami w projekcie. Lista zależnosci standardowo w plikach `Cartfile` i `Podfile`

## Carthage

W folderze `scripts` znajduje się skrypt `updateCarthage.sh` ułatwiający zaktualizowanie zależności obsługiwanych przez Carthage.

# Rodzaje środowisk

Aplikacja ProteGO posiada 3 środowiska:

- development
- staging
- production

Każde ze środowisk:
- kontaktuje się z dedykowanymi, odseparowanymi od siebie sobie serwerami,
- posiada różne ikony aplikacji

Dodatkowo środowisko `development` posiada:

- Menu deweloperskie dostępne po potrząśnięciu telefonem,
- Integrację z serwisem Firebase Crashlytics,
- Integrację z serwisem Bugfender

# Teksty w aplikacji

Aplikacja posiada wsparcie wielu języków. W folderze `scripts` znajduje się skrypt pomocniczy `updateLocalization.sh` który automatycznie ściąga najnowsze teksty z Google Spreadsheet oraz generuje odpowiednie struktury pomocnicze za pomocą SwiftGen.