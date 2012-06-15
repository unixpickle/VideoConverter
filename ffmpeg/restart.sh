# usage: restart.sh x264 libvorbis_path libogg_path libtheora_path
if [ -f config.mak ]; then
	rm config.mak
fi
./configure --disable-yasm --enable-gpl --enable-nonfree --enable-libx264 --enable-avfilter --enable-libvorbis --enable-libtheora "--extra-ldflags=-L$1" "--extra-cflags=-I$1" "--extra-ldflags=-L$2/libs" "--extra-cflags=-I$2/include" "--extra-ldflags=-L$3" "--extra-cflags=-I$3" "--extra-ldflags=-L$4" "--extra-cflags=-I$4"
make clean
