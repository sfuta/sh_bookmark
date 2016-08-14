#!/usr/local/bin/zsh

#add bookmark
#
# @param  $1 save path(default current dir)
# @param  $2 save id  (default auto create:See __sh_bookmark::makeId())
# @return nothing
__sh_bookmark::add ()
{
  ! [ -z $WIDGET ] && zle -I

  local savePath=`[ -z $1 ] && pwd || echo $1`
  local bookmarkPath=`__sh_bookmark::normalizedPath $savePath`

  [ -z $bookmarkPath ] && return 1

  local bookmarkBaseName=`[ -z $2 ] && basename $bookmarkPath || echo $2`
  local bookmarkId=`__sh_bookmark::makeId $bookmarkBaseName`

  [ -z $bookmarkId ] && return 1

  printf "%-18s| %s\n" ${bookmarkId} ${bookmarkPath} >> ${SH_BOOKMARKS_FILE}
  echo "bookmark add > ${bookmarkId}|${bookmarkPath}"
}

#delete bookmark
__sh_bookmark::delete ()
{
  ! [ -z $WIDGET ] && zle -I

  local deleteIds=`__sh_bookmark::select id`

  if [ -n "$deleteIds" ]; then
    #grep -vF "${deleteBookmarkId}" ${SH_BOOKMARKS_FILE} > $tmpfile
    local tmpfile=`mktemp`
    local delLines=""

    echo "start delete bookmarks"
    for deleteId in `echo $deleteIds | tr "\n" " "`; do
      delLines=${delLines}" && NR!="`grep -n "^${deleteId}" ${SH_BOOKMARKS_FILE} | cut -d ":" -f1`
      echo "  bookmark delete > ${deleteId}"
    done
    delLines=`echo ${delLines} | cut -c5-`
    cat  ${SH_BOOKMARKS_FILE} | awk "${delLines}" > $tmpfile
    command cp -f $tmpfile ${SH_BOOKMARKS_FILE}
    command rm -f $tmpfile
    echo "end delete bookmarks"

  fi
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
    bookmarkedPath=`echo ${line} | cut -d "|" -f2- | cut -c2- | sed "s;^~;${HOME};"`
    if [ -e "$bookmarkedPath" ]; then
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
  local selectedPath=`__sh_bookmark::select path`

  if [ -n "$selectedPath" ]; then
    local escapedPath=`echo ${selectedPath} | \
                sed "s/\([\!#$%&'\"\\\`()=~|^\{\}[*?<> ]\)/\\\\\\\\\1/g" | \
                sed "s/]/\\\\\]/g" | \
                sed "s/^\\\\\~/~/"`

    if ! [ -z $WIDGET ]; then
      BUFFER=$BUFFER"${escapedPath}"
    else
      print -z "${escapedPath}"
    fi
  fi
}

