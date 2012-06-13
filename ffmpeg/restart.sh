if [ -f config.mak ]; then
	rm config.mak
fi
./configure --disable-yasm --enable-gpl --enable-nonfree --enable-libx264 --enable-avfilter "--extra-ldflags=-L$1" "--extra-cflags=-I$1"
make clean
