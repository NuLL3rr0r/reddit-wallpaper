## Reddit Wallpaper

A customizable script which automagically fetches a wallpaper from your favorite subreddits.

### Usage

```
Correct usage:

    reddit-wallpaper.sh -h | [-r {r/subreddit}] [-s {sorty by}] [-n] [-b {background color}] [-f 'feh args']

    -h: shows this usage note

    -r: subreddit name or names prefixed with r/ and combined by a + sign (e.g. r/Art or r/Art+ArtPorn; default: r/Art+ArtPorn+Cinemagraphs+ExposurePorn+Graffiti+ImaginaryLandscapes+itookapicture+ImaginaryBehemoths+ImaginaryCharacters+ImaginaryLandscapes+ImaginaryLeviathans+ImaginaryMindscapes+ImaginaryMonsters+ImaginaryTechnology)

    -s: reddit sort algorithm (e.g. hot, new, controversial, top, rising; default: hot)

    -n: allow nsfw wallpapers (no nsfw wallpaper is allowed by default, unless this flag is passed)

    -b: hex rgb color in 'ffffff' format (default: 282828)

    -f: feh arguments to pass; run 'man feh' for a list of available options (default: --no-fehbg --image-bg black --bg-max)
```

e.g.

```
$ ./reddit-wallpaper.sh -r r/Art -s top -n -b "000000"
```

### Running through a cron job

```crontab
$ sudo -u user -g group -H crontab -e

# At minute 0 past every 4th hour
0   */4   *   *   *   export DISPLAY=:0; /path/to/reddit-wallpaper.sh > /dev/null 2>&1
```

Do not forget to:

```
$ chmod a+x /path/to/reddit-wallpaper.sh
```

## User Guide

[Visit this blog post for more information](https://www.babaei.net/blog/my-reddit-wallpaper-downloader-script).

### LICENSE

(The MIT License)

Copyright (c) 2018 - 2019 Mamadou Babaei

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
