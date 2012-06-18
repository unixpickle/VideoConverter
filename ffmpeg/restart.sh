# usage: restart.sh x264 libvorbis_path libogg_path libtheora_path libmodplug_path libfaac_path
if [ -f config.mak ]; then
	rm config.mak
fi
./configure --disable-yasm --enable-gpl --enable-nonfree --enable-libx264 --enable-avfilter --enable-libvorbis --enable-libtheora --enable-libmodplug --enable-libfaac "--extra-ldflags=-L$1" "--extra-cflags=-I$1" "--extra-ldflags=-L$2/libs" "--extra-cflags=-I$2/include" "--extra-ldflags=-L$3" "--extra-cflags=-I$3" "--extra-ldflags=-L$4" "--extra-cflags=-I$4" "--extra-cflags=-I$5" "--extra-ldflags=-L$5" "--extra-cflags=-I$6" "--extra-ldflags=-L$6" --enable-pic "--extra-ldflags=-lstdc++"
make clean
