#!/usr/local/bin/zsh

#add bookmark
#
# @param  $1 save path(default current dir)
# @param  $2 save id  (default auto create:See __sh_bookmark::makeId())
# @return nothing
__sh_bookmark::add ()
{
  ! [ -z $WIDGET ] && zle -I

  if [ -z $1 ]; then
    local bookmarkPath=`__sh_bookmark::normalizedPath $PWD`
  else
    local bookmarkPath=`__sh_bookmark::normalizedPath $1`
  fi
  [ -z $bookmarkPath ] && return 1

  local bookmarkBaseName=`[ -z $2 ] && basename $bookmarkPath || (echo $2 | tr -d " ")`
  local bookmarkId=`__sh_bookmark::makeId $bookmarkBaseName`

  [ -z $bookmarkId ] && return 1

  if grep -e "^${bookmarkId}" ${SH_BOOKMARKS_FILE}  >/dev/null ; then
    echo "already,this bookmark id is registed:"${bookmarkId} >&2;
    return 1;
  fi

  printf "%-18s|%s\n" ${bookmarkId} ${bookmarkPath} >> ${SH_BOOKMARKS_FILE}
  echo "bookmark add > ${bookmarkId}|${bookmarkPath}"
}

#delete bookmark
__sh_bookmark::delete ()
{
  ! [ -z $WIDGET ] && zle -I

  local deleteBookmarkId=`__sh_bookmark::select id`
  if [ -n "$deleteBookmarkId" ]; then
    local tmpfile=`mktemp`
    grep -vF "${deleteBookmarkId}" ${SH_BOOKMARKS_FILE} > $tmpfile
    command cp -f $tmpfile ${SH_BOOKMARKS_FILE}
    command rm -f $tmpfile
  fi
  echo "bookmark delete > ${deleteBookmarkId}"
}

#refresh bookmark (clean file)
__sh_bookmark::refresh ()
{
  local tmpfile=`mktemp`
  local bookmarkedPath=""

  ! [ -z $WIDGET ] && zle -I

  echo "start bookmark refresh"
  while read line
  do
    bookmarkedPath=`echo ${line} | rev | cut -d "|" -f1-1 | rev | sed "s;^~;${HOME};"`
    if [ -e $bookmarkedPath ]; then
      echo $line >> $tmpfile
    else
      echo "  delete bookmark > "`echo ${line} | sed "s; *?\|;\|;"`
    fi
  done < ${SH_BOOKMARKS_FILE}
  command mv -f $tmpfile ${SH_BOOKMARKS_FILE}
  echo "end bookmark refresh"

}

#select bookmark function for command
__sh_bookmark::selected ()
{
  local selectedBookmark=`__sh_bookmark::select path`

  if [ -n "$selectedBookmark" ]; then
    if ! [ -z $WIDGET ]; then
      BUFFER=$BUFFER"${selectedBookmark}"
    else
      print -z "${selectedBookmark}"
    fi
  fi
}

