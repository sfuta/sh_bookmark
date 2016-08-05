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
  local bookmarkPath=`builtin cd $1 && pwd`
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
# 1.Max length:20
# @TODO 2. 各階層の先頭文字で作成(日本語の場合はローマ字) 
# 3.Add seq number to id, prevent of duplicate.
#
# @param  $1 bookmark path
# @return bookmark id
__sh_bookmark::makeId ()
{
  local pathInicial=`echo "$1" | tr "/" "\n" | sed "s/\(^.\).*$/\1/" | tr -d "\n" | cut -c1-20`
  local counter=0
  while __sh_bookmark::isExistId "${pathInicial}:${counter}"
  do
    counter=`expr $counter + 1`
    if [ $counter -gt 99 ]; then
      echo "too many similar id ${pathInicial}:n" >&2;
      return 1;
    fi
  done
  echo "${pathInicial}:${counter}"
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

