## Reddit Wallpaper

A customizable script which automagically fetches a wallpaper from your favorite subreddits.

### Usage

```
Correct usage:

    reddit-wallpaper.sh [-r {r/subreddit}] [-s {sorty by}] [-n] [-b {background color}] [-f 'feh args']

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
