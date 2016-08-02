#!/usr/local/bin/zsh

SH_BOOKMARKS_FILE=${HOME}/.sh_bookmarks

#ファイルがなければ作成
! [ -e ${SH_BOOKMARKS_FILE} ] && touch ${SH_BOOKMARKS_FILE}

#pathの正規化
# 1. ホームディレクトリは~に変更
# 2. 存在しない場合はエラーにする
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
  if cut -d "|" -f2 ${SH_BOOKMARKS_FILE} | grep "${normalizedPath}" > /dev/null; then
    echo "already,this bookmark path is registed" >&2;
    return 1;
  fi
  echo ${normalizedPath}
}

#idの存在チェック
__sh_bookmark::isExistId ()
{
  cut -d "|" -f1 ${SH_BOOKMARKS_FILE} | tr -d " " | grep -Fx "$1" > /dev/null
}

#bookmark idを作成
# 1. 最大20文字
# 2. 各階層の先頭文字で作成(日本語の場合はローマ字)
# 3. 名前が重複した場合はシーケンス番号を追加
# 4. ホームディレクトリは「~」で登録
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

# bookmarkを追加
__sh_bookmark::add ()
{
  if [ -z $1 ]; then
    local bookmarkPath=`__sh_bookmark::normalizedPath $PWD`
  else
    local bookmarkPath=`__sh_bookmark::normalizedPath $1`
  fi
  [ -z $bookmarkPath ] && return 1

  local bookmarkId=`__sh_bookmark::makeId $bookmarkPath`
  [ -z $bookmarkId ] && return 1

  printf "%-23s|%s\n" ${bookmarkId} ${bookmarkPath} >> ${SH_BOOKMARKS_FILE}
}

# bookmarkを表示(peco使用)
__sh_bookmark::list ()
{
}


# bookmarkをreload(未存在なパスを除去)
__sh_bookmark::reload ()
{
}
