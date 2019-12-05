#!/usr/bin/env bash

APP_NAME="企业微信"
FRAMEWORK_NAME=WeChatICU
APP_BUNDLE_PATH="/Applications/${APP_NAME}.app/Contents/MacOS"
APP_EXECUTABLE_PATH="${APP_BUNDLE_PATH}/${APP_NAME}"
APP_EXECUTABLE_BACKUP_PATH="${APP_EXECUTABLE_PATH}_backup"
FRAMEWORK_PATH="${APP_BUNDLE_PATH}/${FRAMEWORK_NAME}.framework"
BUILD_OUTPUT_PATH=./Rely

if [[ ! -f ${APP_EXECUTABLE_PATH} ]]; then
    echo "请检查是否安装 ${APP_NAME} "
    exit 1
fi

if test -f ${APP_EXECUTABLE_BACKUP_PATH}; then
rm -rf ${FRAMEWORK_PATH} ${APP_EXECUTABLE_PATH}
mv ${APP_EXECUTABLE_BACKUP_PATH} ${APP_EXECUTABLE_PATH}
echo "卸载成功, 请重启 ${APP_NAME}"
else
    echo "卸载失败, 可能未安装"
fi




