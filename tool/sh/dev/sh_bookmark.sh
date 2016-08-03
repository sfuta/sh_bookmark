#!/usr/local/bin/zsh

SH_BOOKMARKS_FILE=${HOME}/.sh_bookmarks

#create file to save bookmark data
! [ -e ${SH_BOOKMARKS_FILE} ] && touch ${SH_BOOKMARKS_FILE}

#formated path ($HOME -> ~)
# e.g. $HOME/workspace -> ~/workspace
#
# @param  $1 path
# @return formated path
__sh_bookmark::normalizedPath ()
{
  if ! [ -d $1 ]; then
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
# 1. 最大20文字
# 2. 各階層の先頭文字で作成(日本語の場合はローマ字)
# 3. 名前が重複した場合はシーケンス番号を追加
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

#add bookmark
#
# @param  $1 save path(default current dir)
# @param  $2 save id  (default see __sh_bookmark::makeId())
# @return nothing
__sh_bookmark::add ()
{
  if [ -z $1 ]; then
    local bookmarkPath=`__sh_bookmark::normalizedPath $PWD`
  else
    local bookmarkPath=`__sh_bookmark::normalizedPath $1`
  fi
  [ -z $bookmarkPath ] && return 1

  if [ -z $2 ]; then
    local bookmarkId=`__sh_bookmark::makeId $bookmarkPath`
  else
    local bookmarkId=`echo $2`
  fi
  [ -z $bookmarkId ] && return 1

  printf "%-23s|%s\n" ${bookmarkId} ${bookmarkPath} >> ${SH_BOOKMARKS_FILE}
  echo "bookmark add > ${bookmarkId}|${bookmarkPath}"
}

#show list bookmark(use peco)
__sh_bookmark::list ()
{
  cat ${SH_BOOKMARKS_FILE} | sort -n | \
                      peco | rev     | \
         cut -d "|" -f 1-1 | rev
}

#reload bookmark (clean file)
__sh_bookmark::reload ()
{
  local tmpfile=$(mktemp)
  local bookmarkedPath=""

  echo "start bookmark reload"
  while read line
  do
    bookmarkedPath=`echo ${line} | rev | cut -d "|" -f1-1 | rev | sed "s;^~;${HOME};"`
    if [ -d $bookmarkedPath ]; then
      echo $line >> $tmpfile
    else
      echo "  delete bookmark > "`echo ${line} | sed "s; *?\|;\|;"`
    fi
  done < ${SH_BOOKMARKS_FILE}
  command mv -f $tmpfile ${SH_BOOKMARKS_FILE}
  echo "end bookmark reload"
}

#show selected bookmark
__sh_bookmark::selected ()
{
  local selectedBookmark=`__sh_bookmark::list`

  if [ -n "$selectedBookmark" ]; then
    BUFFER=$BUFFER" ${selectedBookmark}"
  fi
}
