#!/bin/sh
set -e

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/arrived.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/arrived@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/button_grey.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/button_grey@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/button_red.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/button_red@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button-selected.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button-selected@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-black-button@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button-selected.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button-selected@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-gray-button@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button-selected.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button-selected@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-red-button@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-sheet-panel.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/ActionSheet/action-sheet-panel@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-black-button.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-black-button@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-gray-button.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-gray-button@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-red-button.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-red-button@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-window-landscape.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-window-landscape@2x.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-window.png"
install_resource "BlockAlertsAnd-ActionSheets/BlockAlertsDemo/images/AlertView/alert-window@2x.png"
install_resource "Facebook-iOS-SDK/src/FacebookSDKResources.bundle"
install_resource "Facebook-iOS-SDK/src/FBUserSettingsViewResources.bundle"
install_resource "KIImagePager/KIImagePager/KIImagePager/KICamera.png"
install_resource "KIImagePager/KIImagePager/KIImagePager/KICamera@2x.png"
install_resource "SVProgressHUD/SVProgressHUD/SVProgressHUD.bundle"
install_resource "iRate/iRate/iRate.bundle"

rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"
