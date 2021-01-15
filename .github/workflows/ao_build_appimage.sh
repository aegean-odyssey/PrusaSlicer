#!/bin/bash

cd build

URL="https://github.com/AppImage/AppImageKit/releases/latest/download"
wget "$URL/appimagetool-x86_64.AppImage " -O appimagetool-x86_64.AppImage 
chmod a+x appimagetool-x86_64.AppImage 

mkdir -p AppDir/usr/bin/bin

cp -a ../resources AppDir/usr/bin/

cp src/prusa-slicer AppDir/usr/bin/bin
ln -s AppDir/usr/bin/bin/prusa-slicer \
   AppDir/usr/bin/bin/prusa-gcodeviewer

cat <<"EOF" >AppDir/usr/bin/prusa-slicer
#!/bin/sh
DIR="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="$DIR/bin"
exec "$DIR/bin/prusa-slicer" "$@"
EOF
#
cat <<"EOF" >AppDir/usr/bin/prusa-gcodeviewer
#!/bin/sh
DIR="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="$DIR/bin"
exec "$DIR/bin/prusa-gcodeviewer" "$@"
EOF
#
cat <<"EOF" >AppDir/AppRun
#!/bin/sh
NAME="$(basename "$ARGV0")"
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="${HERE}"/usr/bin/:"${PATH}"
[ ! -z $APPIMAGE ] && exec "$HERE/usr/bin/prusa-slicer" "$@"
[ -e "$HERE/usr/bin/$NAME" ] && exec "$HERE/usr/bin/$NAME" "$@"
exec "$HERE/usr/bin/prusa-slicer" "$@"
EOF
#
chmod a+x AppDir/usr/bin/prusa-slicer
chmod a+x AppDir/usr/bin/prusa-gcodeviewer
chmod a+x AppDir/AppRun

cp AppDir/usr/bin/resources/icons/PrusaSlicer_192px.png AppDir/PrusaSlicer.png

cat <<"EOF" >AppDir/PrusaSlicer.desktop
[Desktop Entry]
Name=PrusaSlicer
Exec=AppRun %F
Icon=PrusaSlicer
Type=Application
MimeType=model/stl;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;
Categories=Engineering;Graphics;3DGraphics;
EOF

./appimagetool-x86_64.AppImage AppDir $1
