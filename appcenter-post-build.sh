#!/usr/bin/env bash

echo "Printing environments"
env

if [ "$AGENT_JOBSTATUS" == "Succeeded" ]; then
    echo "Build Succeded"

    if [[ -z "$BUGSNAG_API_KEY" ]]; then
        echo "No BUGSNAG_API_KEY, so won't upload anything to Bugsnag."
    else
        cd $APPCENTER_SOURCE_DIRECTORY
        echo "Start uploading to Bugsnag."

        if [ -n "$APPCENTER_XCODE_PROJECT" ]; then
            echo "This is iOS project"
            
            echo "Generating Source Map"
            #yarn run
            react-native bundle --platform ios --dev false --entry-file index.js --bundle-output ios-release.bundle --sourcemap-output ios-release.bundle.map
            echo "Uploading Source Map"
            curl --http1.1 https://upload.bugsnag.com/react-native-source-map \
                -F apiKey=$BUGSNAG_API_KEY \
                -F appVersion=1.0 \
                -F dev=false \
                -F platform=ios \
                -F sourceMap=@ios-release.bundle.map \
                -F bundle=@ios-release.bundle \
                -F projectRoot=`pwd`
            echo "Done Source Map"

            echo "TODO: upload dSYMs"

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