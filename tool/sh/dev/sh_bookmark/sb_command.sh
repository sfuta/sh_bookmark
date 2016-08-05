#!/usr/local/bin/zsh

#add bookmark
#
# @param  $1 save path(default current dir)
# @param  $2 save id  (default auto create:See __sh_bookmark::makeId())
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

#delete bookmark
__sh_bookmark::delete ()
{
  local deleteBookmarkId=`__sh_bookmark::select id`
  if [ -n "$deleteBookmarkId" ]; then
    local tmpfile=`mktemp`
    grep -vF "${deleteBookmarkId}" ${SH_BOOKMARKS_FILE} > $tmpfile
    command cp -f $tmpfile ${SH_BOOKMARKS_FILE}
    command rm -f $tmpfile
  fi
}

#reload bookmark (clean file)
__sh_bookmark::reload ()
{
  local tmpfile=`mktemp`
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

#select bookmark function for command
__sh_bookmark::selected ()
{
  local selectedBookmark=`__sh_bookmark::select path`

  if [ -n "$selectedBookmark" ]; then
    if [ -z $1 ]; then
      BUFFER=$BUFFER"${selectedBookmark}"
    else
      print -z "${selectedBookmark}"
    fi
  fi
}

