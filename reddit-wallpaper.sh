#!/usr/bin/env bash

#  (The MIT License)
#
#  Copyright (c) 2018 - 2019 Mamadou Babaei
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.


set +e

readonly FMT_OFF='\e[0m'
readonly FMT_INFO='\e[1;32m'
readonly FMT_WARN='\e[1;33m'
readonly FMT_ERR='\e[1;91m'
readonly FMT_FATAL='\e[1;31m'

readonly LOG_INFO="INFO"
readonly LOG_WARN="WARNING"
readonly LOG_ERR="ERROR"
readonly LOG_FATAL="FATAL"

readonly E_TRUE="true"
readonly E_FALSE="false"

readonly BASENAME="basename"
readonly CALLER="caller"
readonly CUT=$(which cut 2>/dev/null)
readonly CURL=$(which curl 2>/dev/null)
readonly DATE=$(which date 2>/dev/null)
readonly ECHO="echo"
readonly ECHO_FMT="echo -e"
readonly ESETROOT=$(which esetroot 2>/dev/null)
readonly FEH=$(which feh 2>/dev/null)
readonly FIREFOX=$(which firefox 2>/dev/null)
readonly HSETROOT=$(which hsetroot 2>/dev/null)
readonly JQ=$(which jq 2>/dev/null)
readonly LOGGER="logger"
readonly PERL=$(which perl 2>/dev/null)
readonly PRINT="print"
readonly REV=$(which rev 2>/dev/null)
readonly TR=$(which tr 2>/dev/null)
readonly XSETROOT=$(which xsetroot 2>/dev/null)

if [[ -n "${ESETROOT}" ]] ;
then
    readonly SETROOT=${ESETROOT}
elif [[ -n "${HSETROOT}" ]] ;
then
    readonly SETROOT=${HSETROOT}
elif [[ -n "${XSETROOT}" ]] ;
then
    readonly SETROOT=${XSETROOT}
fi

readonly SCRIPT="${BASH_SOURCE[0]}"
readonly SCRIPT_NAME="$(${BASENAME} -- "${SCRIPT}")"
readonly SYSLOG_TAG="$(${BASENAME} -- "${SCRIPT}" | ${TR} '[:lower:]' '[:upper:]' | ${REV} | ${CUT} -d "." -f2- | ${REV})"

readonly SUBREDDIT_CATEGORY_ANIMALS="AnimalsBeingBros+AnimalsBeingDerps+AnimalsBeingJerks+aww+Eyebleach+likeus+rarepuppers"
readonly SUBREDDIT_CATEGORY_ART="Art+ArtPorn+Cinemagraphs+ExposurePorn+Graffiti+ImaginaryLandscapes+itookapicture"
readonly SUBREDDIT_CATEGORY_FOOD="Breadit+eatsandwiches+food+FoodPorn+grilledcheese+Pizza+slowcooking"
readonly SUBREDDIT_CATEGORY_IMAGINARY="ImaginaryBehemoths+ImaginaryCharacters+ImaginaryLandscapes+ImaginaryLeviathans+ImaginaryMindscapes+ImaginaryMonsters+ImaginaryTechnology"
readonly SUBREDDIT_CATEGORY_MAN_MADE="AbandonedPorn+carporn+CityPorn+CozyPlaces+DesignPorn+powerwashingporn+RoomPorn"
readonly SUBREDDIT_CATEGORY_NATURE="chemicalreactiongifs+EarthPorn+MacroPorn+physicsgifs+spaceporn+waterporn+WeatherGifs"

readonly DEFAULT_SUBREDDIT="r/${SUBREDDIT_CATEGORY_ART}+${SUBREDDIT_CATEGORY_IMAGINARY}"
readonly DEFAULT_SORT_BY="hot"
readonly DEFAULT_IS_NSFW_OK="${E_FALSE}"
readonly DEFAULT_BACKGROUND_COLOR="282828"
readonly DEFAULT_FEH_ARGS="--no-fehbg --image-bg black --bg-max"

readonly DEFAULT_FIREFOX_VERSION_STRING="Mozilla Firefox 66.0"

readonly LOCAL_WALLPAPER_DIR="${HOME}/.cache/reddit_wallpapers/"
readonly LOCAL_WALLPAPER_NAME="$(${DATE} +%Y-%m-%d-%H-%M-%S)"

function usage() {
    readonly local message="${1}"

    ${ECHO}

    if [[ -n "${message}" ]] ;
    then
        err "${message}${FMT_OFF}"
        ${ECHO}
    fi

    ${ECHO_FMT} "${FMT_INFO}Correct usage:${FMT_OFF}"
    ${ECHO}
    ${ECHO_FMT} "    ${FMT_INFO}${SCRIPT_NAME} -h | [-r {r/subreddit}] [-s {sorty by}] [-n] [-b {background color}] [-f 'feh args']${FMT_OFF}"
    ${ECHO}
    ${ECHO_FMT} "    ${FMT_INFO}-h: shows this usage note"
    ${ECHO}
    ${ECHO_FMT} "    ${FMT_INFO}-r: subreddit name or names prefixed with r/ and combined by a + sign (e.g. r/Art or r/Art+ArtPorn; default: ${DEFAULT_SUBREDDIT})${FMT_OFF}"
    ${ECHO}
    ${ECHO_FMT} "    ${FMT_INFO}-s: reddit sort algorithm (e.g. hot, new, controversial, top, rising; default: ${DEFAULT_SORT_BY})${FMT_OFF}"
    ${ECHO}
    ${ECHO_FMT} "    ${FMT_INFO}-n: allow nsfw wallpapers (no nsfw wallpaper is allowed by default, unless this flag is passed)${FMT_OFF}"
    ${ECHO}
    ${ECHO_FMT} "    ${FMT_INFO}-b: hex rgb color in 'ffffff' format (default: ${DEFAULT_BACKGROUND_COLOR})${FMT_OFF}"
    ${ECHO}
    ${ECHO_FMT} "    ${FMT_INFO}-f: feh arguments to pass; run 'man feh' for a list of available options (default: ${DEFAULT_FEH_ARGS})${FMT_OFF}"
    ${ECHO}

    if [[ -n "${message}" ]] ;
    then
        exit 1
    else
        exit 0
    fi
}

function log()
{
    local log_type=$1; shift
    local line=$1; shift
    local fmt=$1; shift

    if [[ -n "$1" && -n "$@" ]] ;
    then
        ${ECHO_FMT} "${fmt}[${log_type}] ${line} $@${FMT_OFF}"
        ${LOGGER} -t "${SYSLOG_TAG}" "${log_type} ${line} $@"
    else
        ${ECHO_FMT} "${FMT_WARN}[${LOG_WARN}] ${line} A null log detected!${FMT_OFF}"
        ${LOGGER} -t "${SYSLOG_TAG}" "${LOG_WARN} ${line} A null log detected!"
    fi
}

function info()
{
    local line=$( "${ECHO}" $( "${CALLER}" 0 ) | "${CUT}" -d " " -f1 )

    log "${LOG_INFO}" "${line}" "${FMT_INFO}" "$@"
}

function warn()
{
    local line=$( "${ECHO}" $( "${CALLER}" 0 ) | "${CUT}" -d " " -f1 )

    log "${LOG_WARN}" "${line}" "${FMT_WARN}" "$@"
}

function err()
{
    local line=$( "${ECHO}" $( "${CALLER}" 0 ) | "${CUT}" -d " " -f1 )

    log "${LOG_ERR}" "${line}" "${FMT_ERR}" "$@"
}

function fatal()
{
    local line=$( "${ECHO}" $( "${CALLER}" 0 ) | "${CUT}" -d " " -f1 )

    log "${LOG_FATAL}" "${line}" "${FMT_FATAL}" "$@"

    exit 1
}

if [[ -z "${CUT}" ]] ;
then
    fatal "Could not find command cut!"
fi

if [[ -z "${CURL}" ]] ;
then
    fatal "Could not find command curl!"
fi

if [[ -z "${DATE}" ]] ;
then
    fatal "Could not find command date!"
fi

if [[ -z "${FEH}" ]] ;
then
    fatal "Could not find command feh!"
fi

if [[ -z "${JQ}" ]] ;
then
    fatal "Could not find command jq!"
fi

if [[ -z "${PERL}" ]] ;
then
    fatal "Could not find command perl!"
fi

if [[ -z "${REV}" ]] ;
then
    fatal "Could not find command rev!"
fi

if [[ -z "${SETROOT}" ]] ;
then
    fatal "Could not find any setroot command!"
fi

if [[ -z "${TR}" ]] ;
then
    fatal "Could not find command tr!"
fi

while getopts ":h :r: :s: :n :b: :f:" ARG;
do
    case ${ARG} in
        h)
            usage
            ;;
        r)
            SUBREDDIT=${OPTARG}
            ;;
        s)
            SORT_BY=${OPTARG}
            ;;
        n)
            IS_NSFW_OK="${E_TRUE}"
            ;;
        b)
            BACKGROUND_COLOR="#${OPTARG}"
            ;;
        f)
            FEH_ARGS="${OPTARG}"
            ;;
        \?)
            usage "Invalid option: '-${OPTARG}'!"
        ;;
    esac
done

if [[ -z ${SUBREDDIT} ]] ;
then
    SUBREDDIT=${DEFAULT_SUBREDDIT}
fi

readonly SUBREDDIT_REGEX="^r\/([a-zA-Z0-9_+]+)$"

if [[ ! "${SUBREDDIT}" =~ ${SUBREDDIT_REGEX} ]] ;
then
    fatal "Invalid subreddit name! use r/subreddit or r/subreddit1+subreddit2 format!"
fi

if [[ -z ${SORT_BY} ]] ;
then
    SORT_BY=${DEFAULT_SORT_BY}
fi

if [[ "${SORT_BY}" != "hot"
        && "${SORT_BY}" != "new"
        && "${SORT_BY}" != "controversial"
        && "${SORT_BY}" != "top"
        && "${SORT_BY}" != "rising" ]] ;
then
    fatal "Invalid reddit sort algorithm!"
fi

if [[ -z ${IS_NSFW_OK} ]] ;
then
    NSFW_OK=${DEFAULT_IS_NSFW_OK}
fi

if [[ -z ${BACKGROUND_COLOR} ]] ;
then
    BACKGROUND_COLOR="#${DEFAULT_BACKGROUND_COLOR}"
fi

readonly BACKGROUND_COLOR_REGEX="^#([0-9a-f]{6})$"

if [[ ! "${BACKGROUND_COLOR}" =~ ${BACKGROUND_COLOR_REGEX} ]] ;
then
    fatal "Invalid background color format! the only accepted format is 'ffffff'!"
fi

if [[ -z ${FEH_ARGS} ]] ;
then
    FEH_ARGS=${DEFAULT_FEH_ARGS}
fi

if [[ -z "${FIREFOX}" ]] ;
then
    warn "Firefox executable not found!"
    readonly FIREFOX_VERSION_STRING="${DEFAULT_FIREFOX_VERSION_STRING}"
    warn "Setting Firefox version string to: ${FIREFOX_VERSION_STRING}"
else
    readonly FIREFOX_VERSION_STRING=$(${FIREFOX} -version)
fi

readonly FIREFOX_VERSION_NUMBER=$(${ECHO} "${FIREFOX_VERSION_STRING}" | ${PERL} -nle "m/[-+]?([0-9]*\.[0-9]+|[0-9]+)/; ${PRINT} \$1")
readonly FIREFOX_USER_AGENET="Mozilla/5.0 (X11; Linux x86_64; rv:${FIREFOX_VERSION_NUMBER}) Gecko/20100101 Firefox/${FIREFOX_VERSION_NUMBER}"

info "Run '${SCRIPT_NAME} -h' for more information on available options."

info "Setting user agent to '${FIREFOX_USER_AGENET}'..."

readonly JSON_URL="https://www.reddit.com/${SUBREDDIT}/${SORT_BY}.json"

info "Downloading meta file '${JSON_URL}'..."

readonly JSON_CONTENT=$(${CURL} -A "${FIREFOX_USER_AGENET}" -sSL ${JSON_URL})
RC=$?

if [[ $RC -ne 0 ]] ;
then
    fatal "Subreddit meta file download has failed!"
fi

readarray JSON_POSTS <<< "$(${ECHO} "${JSON_CONTENT}" | ${JQ} --compact-output '.data.children[]')"
RCS=(${PIPESTATUS[*]})

if [[ ${RCS[0]} -ne 0 || ${RCS[1]} -ne 0 ]] ;
then
    fatal "Failed to parse the subreddit's meta file!"
fi

readonly URL_REGEX="^(https?://)?(([0-9a-z_!~*'().&=+$%-]+: )?[0-9a-z_!~*'().&=+$%-]+@)?(([0-9]{1,3}\\.){3}[0-9]{1,3}|([0-9a-z_!~*'()-]+\\.)*([0-9a-z][0-9a-z-]{0,61})?[0-9a-z]\\.[a-z]{2,6})(:[0-9]{1,4})?((/?)|(/[0-9a-z_!~*'().;?:@&=+$,%#-]+)+/?)\\.(png|apng|jpg|jpeg|jpe|jif|jfif|jfi|gif|tiff|tif)$"

FOUND_A_SUITABLE_WALLPAPER="${E_FALSE}"

for post in "${JSON_POSTS[@]}" ;
do
    if [[ "${IS_NSFW_OK}" != "${E_TRUE}" ]] ;
    then
        IS_OVER_18_POST=$(${ECHO} "${post}" | ${JQ} --compact-output '.data.over_18')
        RCS=(${PIPESTATUS[*]})

        if [[ ${RCS[0]} -ne 0 || ${RCS[1]} -ne 0 ]] ;
        then
            fatal "Failed to parse the subreddit's meta file!"
        fi

        if [[ "${IS_OVER_18_POST}" == "${E_TRUE}" ]] ;
        then
            continue
        fi
    fi

    WALLPAPER_URL=$(${ECHO} "${post}" | ${JQ} --raw-output '.data.url')
    RCS=(${PIPESTATUS[*]})

    if [[ ${RCS[0]} -ne 0 || ${RCS[1]} -ne 0 ]] ;
    then
        fatal "Failed to parse the subreddit's meta file!"
    fi

    if [[ ! "${WALLPAPER_URL}" =~ ${URL_REGEX} ]] ;
    then
        continue
    fi

    WALLPAPER_EXTENSION="${WALLPAPER_URL##*.}"

    if [[ -z "${WALLPAPER_EXTENSION}" ]] ;
    then
        continue
    fi

    FOUND_A_SUITABLE_WALLPAPER="${E_TRUE}"
    break;
done

if [[ "${FOUND_A_SUITABLE_WALLPAPER}" != "${E_TRUE}" ]] ;
then
    fatal "Could not find a suitable wallpaper on '${SUBREDDIT}'!"
fi

readonly LOCAL_WALLPAPER_PATH="${LOCAL_WALLPAPER_DIR}/${LOCAL_WALLPAPER_NAME}.${WALLPAPER_EXTENSION}"

info "Found a wallpaper on '${SUBREDDIT}' at '${WALLPAPER_URL}'!"
info "Fetching '${WALLPAPER_URL}'..."

${CURL} -fLo "${LOCAL_WALLPAPER_PATH}" --create-dirs ${WALLPAPER_URL} > /dev/null 2>&1
RC=$?

if [[ $RC -ne 0 ]] ;
then
    fatal "Failed to fetch the wallpaper file from '${WALLPAPER_URL}'!"
fi

info "Setting desktop background color to '${BACKGROUND_COLOR}'..."

${SETROOT} -solid "${BACKGROUND_COLOR}" > /dev/null 2>&1 &
RC=$?

if [[ $RC -ne 0 ]] ;
then
    fatal "Failed to set the background color to '${BACKGROUND_COLOR}'!"
fi



info "Using '${WALLPAPER_URL}' as the desktop wallpaper..."

info "Checking if user is using GNOME"

if echo $XDG_CURRENT_DESKTOP | grep ":GNOME" -q > /dev/null
then
    info "User is using GNOME, setting wallpaper with gnome commands (disregarding feh args)"
    gsettings set org.gnome.desktop.background picture-uri "${LOCAL_WALLPAPER_PATH}"
    RC=$?
else 
    ${FEH} ${FEH_ARGS} "${LOCAL_WALLPAPER_PATH}" > /dev/null 2>&1 &
    RC=$?
fi

if [[ $RC -ne 0 ]] ;
then
    fatal "Failed to apply '${LOCAL_WALLPAPER_PATH}' as the desktop background image!"
fi

info "Done!"
info "Hope you enjoy it :)"
