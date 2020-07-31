DEV_PATH=${PROJECT_DIR}/${TARGET_NAME}/Resources/Dev/GoogleService-Info-Dev.plist
STAGE_PATH=${PROJECT_DIR}/${TARGET_NAME}/Resources/Stage/GoogleService-Info-Stage.plist
LIVE_PATH=${PROJECT_DIR}/${TARGET_NAME}/Resources/Live/GoogleService-Info-Live.plist

DESTINATION=${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist

case "${CONFIGURATION}" in
    "Dev")                cp -r "${DEV_PATH}" "${DESTINATION}";;
    "Stage"|"StageDebug"|"StageScreencast") cp -r "${STAGE_PATH}" "${DESTINATION}";;
    "Live"|"LiveDebug")   cp -r "${LIVE_PATH}" "${DESTINATION}";;
    *) ;;
esac