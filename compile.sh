# compile libogg
echo "Compiling libogg" >&2
libogg_path="${SRCROOT}/libogg-1.3.0"
cd "$libogg_path"
if [ -d lib ]; then
    rm -rf lib
fi
mkdir lib
./configure "--libdir=${libogg_path}/lib" "--includedir=${libogg_path}/lib" --disable-shared
make clean
make
make install

# compile libvorbis
echo "Compiling libvorbis" >&2
libvorbis_path="${SRCROOT}/vorbis"
if [ ! -d "${libvorbis_path}/libs" ]; then
    mkdir "${libvorbis_path}/libs"
else
    rm -rf "${libvorbis_path}/libs/*"
fi
cd "$libvorbis_path"
./configure  --build=x86_64
./configure "--with-ogg=${libogg_path}" "--with-ogg-includes=${libogg_path}/lib" --build=x86_64 --enable-static "--libdir=${libvorbis_path}/libs"
make clean
make install

# compile libtheora :'(
echo "Compiling libtheora" >&2
libtheora_path="${SRCROOT}/libtheora-1.1.1"
if [ ! -d "${libtheora_path}/output" ]; then
    mkdir "${libtheora_path}/output"
else
    rm -rf "${libtheora_path}/output/*"
fi
cd "$libtheora_path"
./configure --enable-static "--with-vorbis-includes=${libvorbis_path}/include" "--with-vorbis-libraries=${libvorbis_path}/libs" "--with-ogg-includes=${libogg_path}/lib" "--with-ogg-libraries=${libogg_path}/lib" "--libdir=${libtheora_path}/output" "--includedir=${libtheora_path}/output" --build=x86_64
make install

# compile x264
echo "Compiling x264" >&2
cd "${SRCROOT}/x264"
make clean
if [ -f config.mak ]; then
    rm config.mak
fi
./configure --enable-static --disable-asm
make

# compile libmodplug
echo "Compiling libmodplug" >&2
libmodplug_path="${SRCROOT}/libmodplug-0.8.8.4"
cd "$libmodplug_path"
if [ -d output ]; then
	rm -rf output
fi
mkdir output
./configure --build=x86_64 --enable-static --disable-shared "--libdir=${libmodplug_path}/output" "--includedir=${libmodplug_path}/output" --with-pic
make clean
make install

# compile libfaac
echo "Compiling libfaac"
libfaac_path="${SRCROOT}/faac-1.28"
cd "${libfaac_path}"
if [ -d output ]; then
	rm -rf output
fi
mkdir output
./configure --build=x86_64 --enable-static --disable-shared "--libdir=${libfaac_path}/output" "--includedir=${libfaac_path}/output"
make clean
make install

# compile ffmpeg
echo "Compiling FFMpeg" >&2
cd "${SRCROOT}/ffmpeg"
sh restart.sh ../x264 ../vorbis ../libogg-1.3.0/lib "${libtheora_path}/output" "${libmodplug_path}/output" "${libfaac_path}/output"
make
execPath="${CONFIGURATION_BUILD_DIR}/${EXECUTABLE_PATH}"
if [ -f "$execPath" ]; then
    rm "$execPath"
fi
if [ ! -d "${CONFIGURATION_BUILD_DIR}" ]; then
    mkdir "${CONFIGURATION_BUILD_DIR}"
fi
cp ffmpeg "$execPath"
