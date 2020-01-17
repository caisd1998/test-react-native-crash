#!/usr/bin/env bash

echo "Printing environment to help trouble shooting"
env

if [ "$AGENT_JOBSTATUS" == "Succeeded" ]; then
    echo "Build Succeded"

    # BUGSNAG_API_KEY is set in app center build setting
    if [ -z "$BUGSNAG_API_KEY" ]; then
        echo "No BUGSNAG_API_KEY, so won't upload anything to Bugsnag."
    else
        echo "Start uploading to Bugsnag."

        if [ -n "$APPCENTER_XCODE_PROJECT" ]; then
            echo "This is iOS project"

            # Here we don't support finding marketing version older than xcode 11.
            # If there's no marketing version, you can simply use xcode 11 to update target to automatically have it.
            cd $APPCENTER_SOURCE_DIRECTORY/ios
            export APP_VERSION=`/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -scheme $APPCENTER_XCODE_SCHEME -showBuildSettings | grep "MARKETING_VERSION" | sed 's/[ ]*MARKETING_VERSION = //'`
            if [ -z "$APP_VERSION" ]; then
                echo "Failed to find app version, exit 1"
                exit 1
            fi
            echo "Found app version $APP_VERSION"
            
            echo "Generating Source Map"
            cd $APPCENTER_SOURCE_DIRECTORY
            yarn run react-native bundle --platform ios --dev false --entry-file index.js --bundle-output ios-release.bundle --sourcemap-output ios-release.bundle.map
            echo "Uploading Source Map"
            curl --http1.1 https://upload.bugsnag.com/react-native-source-map \
                -F apiKey=$BUGSNAG_API_KEY \
                -F appVersion=$APP_VERSION \
                -F dev=false \
                -F platform=ios \
                -F sourceMap=@ios-release.bundle.map \
                -F bundle=@ios-release.bundle \
                -F projectRoot=`pwd`
            echo "Done Source Map"

            echo "Uploading dSYMs"
            # Here we reuse the dysm generated by appcenter build.
            # By analyzing the build log, we found the output directory is somewhere/1/a/build/, and the symbols directory is somewhere/1/a/symbols/, so we can use the relative location to find dsym.
            # We also hardcode the dsym name, so need to change by app name if use this script for another app.
            cd $APPCENTER_OUTPUT_DIRECTORY/../symbols/
            curl --http1.1 https://upload.bugsnag.com/ \
                -F apiKey=$BUGSNAG_API_KEY \
                -F dsym=@MyApp.app.dSYM/Contents/Resources/DWARF/MyApp
            echo "Done dSYMs"

        elif [ -n "$APPCENTER_ANDROID_VARIANT" ]; then
            echo "This is Android project"
            
            cd $APPCENTER_SOURCE_DIRECTORY/android
            export APP_VERSION=`./gradlew -q printVersionName`
            export VERSION_CODE=`./gradlew -q printVersionCode`
            export APPLICATION_ID=`./gradlew -q printApplicationId`
            echo "Found app version $APP_VERSION"
            echo "Found version code $VERSION_CODE"
            echo "Found application id $APPLICATION_ID"

            echo "Generating Source Maps"
            cd $APPCENTER_SOURCE_DIRECTORY
            yarn run react-native bundle --platform android --dev false --entry-file index.js --bundle-output android-release.bundle --sourcemap-output android-release.bundle.map
            echo "Uploading Source Map"
            curl --http1.1 https://upload.bugsnag.com/react-native-source-map \
                -F apiKey=$BUGSNAG_API_KEY \
                -F appVersion=$APP_VERSION \
                -F dev=false \
                -F platform=android \
                -F sourceMap=@android-release.bundle.map \
                -F bundle=@android-release.bundle \
                -F projectRoot=`pwd`
            echo "Done Source Map"

            echo "Upload proguard mapping file"
            # Here we reuse the mapping file generated by appcenter build.
            # By analyzing the build log, we found the output directory is somewhere/1/a/build/, and the mapping file is somewhere/1/a/mapping/mapping.txt, so we can use the relative location to find it.
            curl --http1.1 https://upload.bugsnag.com/ \
                -F proguard=@$APPCENTER_OUTPUT_DIRECTORY/../mapping/mapping.txt \
                -F apiKey=$BUGSNAG_API_KEY \
                -F versionCode=$VERSION_CODE \
                -F appId=$APPLICATION_ID \
                -F versionName=$APP_VERSION
            echo "Done mapping file"

        else
            echo "This is not either iOS or Android project"
        fi
    fi
else
    echo "Build Failed"
fi