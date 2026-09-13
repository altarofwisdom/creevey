sed -i '' -e 's/filenamesDone = YES;/NSLog(@"[Debug] Filter finished. filenames.count = %lu, searchString = \\"%@\\"", (unsigned long)filenames.count, self.searchString);\n\t\tfilenamesDone = YES;/g' CreeveyMainWindowController.m
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild build -project creevey.xcodeproj -scheme "Phoenix Slides" -configuration Release CODE_SIGN_IDENTITY= CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO > /dev/null
rm -rf "/Applications/Phoenix Slides.app" && cp -R "DerivedData/creevey/Build/Products/Release/Phoenix Slides.app" "/Applications/"
killall "Phoenix Slides" ; sleep 1 ; /Applications/Phoenix\ Slides.app/Contents/MacOS/Phoenix\ Slides /Volumes/ai/ComfyUI/output > /tmp/phoenix_debug2.log 2>&1 &
sleep 4
osascript -e 'tell application "System Events" to keystroke "f" using {command down}'
sleep 1
osascript -e 'tell application "System Events" to keystroke "woman"'
sleep 2
cat /tmp/phoenix_debug2.log
