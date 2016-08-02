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
    echo "no such file or directory";
    exit 1;
  fi
  builtin cd `dirname $1`

  if cut -d "|" -f2 ${SH_BOOKMARKS_FILE} | grep "${PWD}"; then
    echo "already,this path is registed";
    kill -INT $$
  fi

  if echo ${PWD} | grep "^${HOME}"; then
    return ${PWD}
  else
    return `echo ${PWD} | sed "s;^${HOME};~;"`
  fi
}

#idの存在チェック
__sh_bookmark::isExistId ()
{
  return cut -d "|" -f1 ${SH_BOOKMARKS_FILE} | grep "$1"
}

#bookmark idを作成
# 1. 最大13文字
# 2. 各階層の先頭文字で作成(日本語の場合はローマ字)
# 3. 名前が重複した場合はシーケンス番号を追加
# 4. ホームディレクトリは「~」で登録
__sh_bookmark::makeId ()
{
  local pathInicial=`echo "$1" | grep -o "/." | tr -d "\r\n/"`
  local counter=0
  while __sh_bookmark::isExistId "${pathInicial}${counter}"
  do
    $counter = $counter + 1
    if [ $counter -gt 99 ]; then
      echo "too many similar id:${pathInicial}"; exit 1;
    fi
  done
  return printf "%-15s|" "${pathInicial}${counter}"
}

# bookmarkを追加
__sh_bookmark::add ()
{
  if [ -n $1 ]; then
    local path=`__sh_bookmark::normalizedPath $1`
  else
    local path=`__sh_bookmark::normalizedPath "."`
  fi
  local id=`__sh_bookmark::makeId $path`
  echo $id$path
}

# bookmarkを表示(peco使用)
__sh_bookmark::list ()
{
}


# bookmarkをreload(未存在なパスを除去)
__sh_bookmark::reload ()
{
}
