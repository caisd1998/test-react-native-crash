#!/usr/bin/env bash

echo "Printing environments"
env

if [ "$AGENT_JOBSTATUS" == "Succeeded" ]; then
    echo "Build Succeded"

    # BUGSNAG_API_KEY is set by us
    if [ -z "$BUGSNAG_API_KEY" ]; then
        echo "No BUGSNAG_API_KEY, so won't upload anything to Bugsnag."
    else
        echo "Start uploading to Bugsnag."
        cd $APPCENTER_SOURCE_DIRECTORY

        if [ -n "$APPCENTER_XCODE_PROJECT" ]; then
            echo "This is iOS project"

            # Here we don't support finding marketing version older than xcode 11.
            # If there's no marketing version, simply use xcode 11 to update target to automatically have it.
            cd ios
            MARKETING_VERSION = `/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -scheme $APPCENTER_XCODE_SCHEME -showBuildSettings | grep "MARKETING_VERSION" | sed 's/[ ]*MARKETING_VERSION = //'`
            if [ -z "$MARKETING_VERSION" ]; then
                echo "Failed to find marketing version, exit"
                return 1
            fi
                echo "Found marketing version $MARKETING_VERSION"
            cd ..
            
            echo "Generating Source Map"
            yarn run react-native bundle --platform ios --dev false --entry-file index.js --bundle-output ios-release.bundle --sourcemap-output ios-release.bundle.map
            echo "Uploading Source Map"
            curl --http1.1 https://upload.bugsnag.com/react-native-source-map \
                -F apiKey=$BUGSNAG_API_KEY \
                -F appBundleVersion=$MARKETING_VERSION \
                -F dev=false \
                -F platform=ios \
                -F sourceMap=@ios-release.bundle.map \
                -F bundle=@ios-release.bundle \
                -F projectRoot=`pwd`
            echo "Done Source Map"

            echo "Uploading dSYMs"
            # here we hardcode the location based on analysis result on appcenter build
            # say the output directory is 1/a/build/, and the symbols directory is 1/a/symbols/
            # we also hardcode the dsym name, so need to change by app name
            cd $APPCENTER_OUTPUT_DIRECTORY/../symbols/
            curl --http1.1 https://upload.bugsnag.com/ \
                -F apiKey=$BUGSNAG_API_KEY \
                -F dsym=@MyApp.app.dSYM/Contents/Resources/DWARF/MyApp
            echo "Done dSYMs"

        elif [ -n "$APPCENTER_ANDROID_VARIANT" ]; then
            echo "This is Android project"
            
            echo "Generating Source Maps"
            #yarn run
            react-native bundle --platform android --dev false --entry-file index.js --bundle-output android-release.bundle --sourcemap-output android-release.bundle.map
            echo "Uploading Source Map"
            curl --http1.1 https://upload.bugsnag.com/react-native-source-map \
                -F apiKey=$BUGSNAG_API_KEY \
                -F appVersion=1.0 \
                -F dev=false \
                -F platform=android \
                -F sourceMap=@android-release.bundle.map \
                -F bundle=@android-release.bundle \
                -F projectRoot=`pwd`
            echo "Done Source Map"

            echo "TODO: upload mapping file"

        else
            echo "This is not either iOS or Android project"
        fi
    fi
else
    echo "Build Failed"
fi