VideoConverter
==============

This is a plug-in for [AutoConvert](https://github.com/unixpickle/AutoConvert) which makes use of the ffmpeg command-line interface.  Using this plug-in, it is easy and straightforward to convert video files in many different containers, and with many different formats.  Currently, this plug-in can encode H.264, OGG+Vorbis, and several other formats.

FFMPEGAudio
===========

This is another [AutoConvert](https://github.com/unixpickle/AutoConvert) plug-in which makes use of the same ffmpeg installation as VideoConvert, except for the sake of converting audio.  This plug-in can currently convert between wav, flac, and xm files.  AutoConvert then uses encoder bridging to convert between wav and other supported formats.  This allows formats such as mp3, which FFMPEGAudio does not support, to be converted to formats that only FFMPEGAudio supports.
