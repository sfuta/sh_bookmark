#!/usr/local/bin/zsh

SH_BOOKMARKS_FILE=${HOME}/.sh_bookmarks

#create file to save bookmark data
! [ -e ${SH_BOOKMARKS_FILE} ] && touch ${SH_BOOKMARKS_FILE}

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
  if [ -d $1 ]; then
    local bookmarkPath=`builtin cd $1 && pwd`
  else
    local bookmarkPath=`pwd`"/$1"
  fi
  local normalizedPath="";

  if echo ${bookmarkPath} | grep \"^${HOME}\" > /dev/null; then
    normalizedPath=`echo ${bookmarkPath}`
  else
    normalizedPath=`echo ${bookmarkPath} | sed "s;^"${HOME}";~;"`
  fi
  if cut -d "|" -f2 ${SH_BOOKMARKS_FILE} | grep -Fx "${normalizedPath}" > /dev/null; then
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
  cut -d "|" -f1 ${SH_BOOKMARKS_FILE} | tr -d " " | grep -Fx "$1" > /dev/null
}

#create bookmark id
# 1.Max length:15
# 2.Add seq number to id, prevent of duplicate.
#
# @param  $1 bookmark path
# @return bookmark id
__sh_bookmark::makeId ()
{
  local baseName=`echo "$1" | cut -c1-15`
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
  local bookmarkLine=`cat ${SH_BOOKMARKS_FILE} | sort -n | peco`
  case "-$1" in
    "-id")   echo ${bookmarkLine} | cut -d "|" -f 1-1 | tr -d " ";;
    "-path") echo ${bookmarkLine} | rev | cut -d "|" -f 1-1 | rev;;
  esac
}

