# ZoomBackgroundMagick
Shell scripts to leverage ffmpeg for the purpose of creating background videos
Requires MacOS Catalina or newer

Resulting videos too long? Here are some quick-and-dirty examples to make them scroll faster and reduce their size:

```
ffmpeg -i ./background_movie_name.mp4 -filter:v "setpts=PTS/4" background_movie_name_4xfaster.mp4

ffmpeg -i ./background_movie_name.mp4 -filter:v "setpts=PTS/3" background_movie_name_3xfaster.mp4

ffmpeg -i ./background_movie_name.mp4 -filter:v "setpts=PTS/2" background_movie_name_2xfaster.mp4
```

`ffmpeg` is capable of doing many other operations, including trimming/cutting/splicing. Have fun!
