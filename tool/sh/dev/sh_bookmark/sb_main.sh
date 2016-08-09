#!/usr/local/bin/zsh

source `dirname $0`/sb_core.sh
source `dirname $0`/sb_command.sh

sh_bookmark ()
{
  case "-$1" in
    "-")   __sh_bookmark::selected;;
    "--a") __sh_bookmark::add $2 $3;;
    "--d") __sh_bookmark::delete;;
    "--r") __sh_bookmark::refresh;;
    "--h")
      echo "bookmark command for zsh"
      echo "  "$0"                show registed bookmark list"
      echo "  "$0" -a [path] [id] add bookmark"
      echo "  "$0" -d             delete bookmark(use peco)"
      echo "  "$0" -r             refresh bookmark path"
    ;;
    *)
      echo "illegal option "$1
      echo "please check option:use \""$0" -h\" show help"
    ;;
  esac
}

zle -N __sh_bookmark::selected
zle -N __sh_bookmark::add
zle -N __sh_bookmark::delete
zle -N __sh_bookmark::refresh
bindkey "^y^y" __sh_bookmark::selected
bindkey "^y^h" __sh_bookmark::add;
bindkey "^y^g" __sh_bookmark::delete
bindkey "^y^t" __sh_bookmark::refresh
