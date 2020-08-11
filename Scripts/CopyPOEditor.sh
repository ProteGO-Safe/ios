# check if SwiftyPoeditor available
# and install if not available
# brew install codemeister64/swiftypoeditor/swiftypoeditor
# run SwiftyPoeditor

echo "SwiftyPoeditor start execution"

swifty-poeditor download -t API_TOKEN -i PROJECT_ID -l en -d "PROJECT_DIR/TARGET_NAME/Resources/Translations/en.strings" -e apple_strings --yes --short-output

echo "SwiftyPoeditor end execution"
