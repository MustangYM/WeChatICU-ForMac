#!/usr/bin/env bash

APP_NAME="企业微信"
FRAMEWORK_NAME=WeChatICU
APP_BUNDLE_PATH="/Applications/${APP_NAME}.app/Contents/MacOS"
APP_EXECUTABLE_PATH="${APP_BUNDLE_PATH}/${APP_NAME}"
APP_EXECUTABLE_BACKUP_PATH="${APP_EXECUTABLE_PATH}_backup"
FRAMEWORK_PATH="${APP_BUNDLE_PATH}/${FRAMEWORK_NAME}.framework"
BUILD_OUTPUT_PATH=./Rely


    if test ! -f ${APP_EXECUTABLE_PATH}; then
        echo "请检查是否安装 ${APP_NAME} "
        exit 1
    fi

    if test ! -w ${APP_BUNDLE_PATH}; then
        echo -e "\n\n请输入密码 ： "
        sudo chown -R $(whoami) "${APP_BUNDLE_PATH}"
    fi

    if test -f ${APP_EXECUTABLE_BACKUP_PATH}; then
        read -t 150 -p "已安装小助手，是否覆盖？[y/n]:" confirm
        if [[ "${confirm}" == 'y' ]]; then
            rm -rf ${FRAMEWORK_PATH}
            cp -R "${BUILD_OUTPUT_PATH}/${FRAMEWORK_NAME}.framework" ${FRAMEWORK_PATH}
            echo "更新成功, 重启 ${APP_NAME} 生效"
        else
            echo "取消安装"
        fi
    else
        rm -rf ${FRAMEWORK_PATH}
        cp -R "${BUILD_OUTPUT_PATH}/${FRAMEWORK_NAME}.framework" ${FRAMEWORK_PATH}
        cp ${APP_EXECUTABLE_PATH} ${APP_EXECUTABLE_BACKUP_PATH}
        ./insert_dylib ${FRAMEWORK_PATH}/${FRAMEWORK_NAME} ${APP_EXECUTABLE_BACKUP_PATH} ${APP_EXECUTABLE_PATH} --all-yes
        echo "安装成功, 重启 ${APP_NAME} 生效"
    fi

