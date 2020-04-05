# ProteGO iOS application


## Project setup

The ProteGO application uses Carthage and CocoaPods to manage dependencies in the project. List of dependencies by default in the files `Cartfile` and` Podfile`
 
 * Installation of Ruby Gems (including CocoaPods): `bundle install`
 * Carthage installation: [there are several possible options](https://github.com/Carthage/Carthage#installing-carthage)
 * Update dependencies managed by Carthage: `. / Scripts / updateCarthage.sh`

## Environments

The ProteGO application has several work environments that have been described [here](https://github.com/ProteGO-app/specs/blob/master/specs/app_versions.md)

## Text translations

The application has multi-language support. The `scripts` folder contains the helper script` updateLocalization.sh` which automatically downloads the latest texts from Google Spreadsheet and generates the appropriate support structures using SwiftGen.
