Aplikacja Anna iOS

# Zależności

Aplikacja Anna wykorzystuje Carthage oraz Cocoapods do zarządzania zależnościami w projekcie. Lista zależnosci standardowo w plikach `Cartfile` i `Podfile`

## Carthage

W folderze `scripts` znajduje się skrypt `updateCarthage.sh` ułatwiający zaktualizowanie zależności obsługiwanych przez Carthage.

# Rodzaje środowisk

Aplikacja Anna posiada 3 środowiska:

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