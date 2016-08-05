#!/usr/local/bin/zsh

source `dirname $0`/sb_core.sh
source `dirname $0`/sb_command.sh

sh_bookmark ()
{
  [ -z $1 ] && __sh_bookmark::selected "a";

  case "-$1" in
    "--a") __sh_bookmark::add $2 $3;;
    "--d") __sh_bookmark::delete;;
    "--r") __sh_bookmark::reload;;
    "*")   echo "message記載予定";;
  esac
}
