#!/bin/bash

VENV_PATH=venv
LOCALIZATION_OUTPUT_PATH=ProteGO
GSHEET_KEY=1DkOwDWwbPxThhbkf5UmkRyGVaNtoikhJAyy555kcpkI
GSHEET_CREDENTIALS_PATH=scripts/Localization/export-gsheet-to-app-resources/localization_credentials.json
GSHEET_EXPORTER_SCRIPT_PATH=scripts/Localization/export-gsheet-to-app-resources/export.py
GSHEET_EXPORTER_REQUIREMENTS_PATH=scripts/Localization/export-gsheet-to-app-resources/requirements.txt
SWIFTGEN_PATH=Pods/SwiftGen/bin/swiftgen
SWIFTGEN_CONFIG_PATH=scripts/Localization/swiftgen.yml     

if [ ! -f $GSHEET_CREDENTIALS_PATH ]; then
   echo "Google credentials file not found at $GSHEET_CREDENTIALS_PATH."
   exit 1
fi

cd "$(dirname "$0")/.."
python3 -m venv $VENV_PATH
source $VENV_PATH/bin/activate
python3 -m pip install -r $GSHEET_EXPORTER_REQUIREMENTS_PATH
python3 $GSHEET_EXPORTER_SCRIPT_PATH --credentials $GSHEET_CREDENTIALS_PATH --gsheet_key $GSHEET_KEY --ios_res $LOCALIZATION_OUTPUT_PATH
$SWIFTGEN_PATH config run --config $SWIFTGEN_CONFIG_PATH