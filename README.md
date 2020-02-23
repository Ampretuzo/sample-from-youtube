Takes descriptive file like this:

```
- Tropea ‎– Short Trip To Space (1977)          | https://www.youtube.com/watch?v=5ZRQYDoDRkU

07:26 - 07:29       | Little Snippet

16:25 - 18:05       | beginning of Short Trip To Space


- From's Power On!                              | https://www.youtube.com/watch?v=HjpjG030yD8   

7:50 - 9:33         | Drum break!

```

And "materializes" it as audio files:
```console
$ ./sample_from_youtube.bash
Downloading 5ZRQYDoDRkU complete.
Done: Tropea_‎–_Short_Trip_To_Space_(1977)__Little_Snippet.wav
Done: Tropea_‎–_Short_Trip_To_Space_(1977)__beginning_of_Short_Trip_To_Space.wav
Downloading HjpjG030yD8 complete.
Done: From's_Power_On!__Drum_break!.wav
$ ls ~/samples.out
'From'\''s_Power_On!__Drum_break!.wav'
'Tropea_–_Short_Trip_To_Space_(1977)__beginning_of_Short_Trip_To_Space.wav'
'Tropea_–_Short_Trip_To_Space_(1977)__Little_Snippet.wav'
```