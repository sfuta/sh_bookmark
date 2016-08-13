#!/usr/local/bin/zsh

#formatted path ($HOME -> ~)
#
# @param  $1 path
# @return formated path
__sh_bookmark::normalizedPath ()
{
  if ! [ -e $1 ]; then
    echo "no such file or directory" >&2;
    return 1;
  fi

  local bookmarkPath=`[ -d $1 ] && (builtin cd $1 && pwd) || echo $PWD"/$1"`
  local normalizedPath=`echo ${bookmarkPath} | sed "s;^"${HOME}";~;"`;

  if cut -d "|" -f2- ${SH_BOOKMARKS_FILE} | grep -Fx " ${normalizedPath}" > /dev/null; then
    echo "already,this bookmark path is registed" >&2;
    return 1;
  fi

  echo ${normalizedPath}
}

#exist check for bookmark id
#
# @param  $1 bookmark id
# @return nothing
__sh_bookmark::isExistId ()
{
  awk 'BEGIN{FS=" "}{print $1}' ${SH_BOOKMARKS_FILE} | grep -Fx "$1" > /dev/null
}

#create bookmark id
# 1.Max length:15
# 2.Add seq number to id, prevent of duplicate.
#
# @param  $1 bookmark path
# @return bookmark id
__sh_bookmark::makeId ()
{
  if echo "$1" | command grep -e "[ |]" > /dev/null; then
    echo "The unusable character remove from id. (' ', '|')" >&2
  fi
  local baseName=`echo "$1" | tr -d " |" | cut -c1-15`
  local counter=0
  while __sh_bookmark::isExistId "${baseName}:${counter}"
  do
    counter=`expr $counter + 1`
    if [ $counter -gt 99 ]; then
      echo "too many similar id ${baseName}:n" >&2;
      return 1;
    fi
  done
  echo "${baseName}:${counter}"
}

#show bookmark list and select(use peco)
__sh_bookmark::select ()
{
  local selectLines=`cat ${SH_BOOKMARKS_FILE} | sort -n | peco --prompt="Bookmark>"`
  case "-$1" in
    "-id")   echo ${selectLines} | awk 'BEGIN{FS=" "}{print $1}';;
    "-path") echo ${selectLines} | cut -d "|" -f2- | cut -c2-;;
  esac
}
