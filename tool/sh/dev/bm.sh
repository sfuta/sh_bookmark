#!/usr/local/bin/zsh

SH_BOOKMARKS_FILE=${HOME}/.sh_bookmarks

#ファイルがなければ作成
[ -e ${SH_BOOKMARKS_FILE} ] && touch ${SH_BOOKMARKS_FILE}

#pathの正規化
# 1. ホームディレクトリは~に変更
# 2. 存在しない場合はエラーにする
__sh_bookmark::normalizedPath ()
{
  [ -n $1 ] && local path=$1 || local path=`pwd`
  if ! [ -d ${path} ]; then
    echo "no such file or directory";
    exit 1;
  fi
#  a\!\"\#\$%\&\'\(\)-=\^\|\\@\`\{\[\]\}\*:+\;\<\>/_\?.,
  if [ -z echo ${path} | grep -E "^${HOME}" ]; then
    return ${path}
  else
    return `echo ${path} | sed "s;^${HOME};~;"`
  fi
}

#bookmark idを作成
# 1. 最大13文字
# 2. 各階層の先頭文字で作成(日本語の場合はローマ字)
# 3. 名前が重複した場合はシーケンス番号を追加
# 4. ホームディレクトリは「~」で登録
__sh_bookmark::isNotExistId ()
{
  return [ -n cut -d "|" -f1 ${SH_BOOKMARKS_FILE} | grep "$1" ]
}
__sh_bookmark::makeId ()
{
  local pathInicial=`echo "$1" | tr "/" "\n" | sed "s/\(^.\).*$/\1/" | tr -d "\n" | cut -c1-13`

  __sh_bookmark::isNotExistId "${pathInicial}"  && return "${pathInicial}"
  __sh_bookmark::isNotExistId "${pathInicial}1" && return "${pathInicial}1"
  __sh_bookmark::isNotExistId "${pathInicial}2" && return "${pathInicial}2"
}


# bookmarkを表示(peco使用)
__sh_bookmark::list ()
{
}

# bookmarkを追加
__sh_bookmark::add ()
{
}

# bookmarkをreload(未存在なパスを除去)
__sh_bookmark::reload ()
{
}
