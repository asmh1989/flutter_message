#!/bin/sh

pwd=`pwd`
uKey=9812388432113be529db985e3ba38224
_api_key=7985c2827257ea59c9559e929a880dd9
projectName='Runner'
scheme='Runner'
info_plist=${pwd}/ios/Runner/info.plist
workspace=Runner.xcworkspace

uploadIos() {

    configurationBuildDir="`pwd`/build"

    archivePath="${configurationBuildDir}/${scheme}.xcarchive"
    exportOptionsPlist="`pwd`/AdHocExportOptions.plist"
    exportPath="${configurationBuildDir}";

    version=`/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' ${info_plist}`

    cd ${pwd}/ios

    newVersion=${version}.`date +%y%m%d%H%M`

    xcodebuild clean -configuration "Release"

    /usr/libexec/PlistBuddy ${info_plist} -c "Set CFBundleShortVersionString ${newVersion}"

    xcodebuild archive -workspace "${workspace}" -scheme "${scheme}" -configuration "Release" -archivePath "${archivePath}"

    xcodebuild -exportArchive -archivePath "${archivePath}" -exportOptionsPlist "${exportOptionsPlist}" -exportPath "${exportPath}"

    cd ${pwd}

    git checkout -- ios

    ios_build_file=${pwd}/build/Runner.ipa

    ios_release_file=${pwd}/build/FMessage_${newVersion}_`git log --oneline --pretty=format:"%h" | head -n 1`.ipa

    cp ${ios_build_file} ${ios_release_file}

    echo "开始上传 ${ios_release_file} 到蒲公英...."
    curl -F "file=@${ios_release_file}" -F "_api_key=${_api_key}" https://www.pgyer.com/apiv2/app/upload
}

if [ "$1" = "ios" ]; then
    echo "build ios release ..."
    flutter build ios --release -t lib/main_publish.dart
    uploadIos
else
    echo "build android release ..."
    flutter build apk --release -t lib/main_publish.dart
fi