DEV_PATH=${PROJECT_DIR}/${TARGET_NAME}/Resources/Dev/Config-dev.plist
STAGE_PATH=${PROJECT_DIR}/${TARGET_NAME}/Resources/Stage/Config-stage.plist
LIVE_PATH=${PROJECT_DIR}/${TARGET_NAME}/Resources/Live/Config-live.plist

case "${CONFIGURATION}" in
    "Dev")                cp -r "${DEV_PATH}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Config-dev.plist";;
    "Stage"|"StageDebug"|"StageScreencast") cp -r "${STAGE_PATH}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Config-stage.plist";;
    "Live"|"LiveDebug")   cp -r "${LIVE_PATH}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Config-live.plist";;
    *) ;;
esac