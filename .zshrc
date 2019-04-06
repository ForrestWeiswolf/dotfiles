# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/forrest/.oh-my-zsh


export PATH="/anaconda3/bin:$PATH/"

# export PATH="/usr/local/bin/python3:$PATH/"

# virtualenvwrapper for python 3:
# source /usr/local/bin/virtualenvwrapper.sh

# virtualenvwrapper for python 2:
# export PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin/python2:$PATH"
# export WORKON_HOME=$HOME/.virtualenvs
# source /Library/Frameworks/Python.framework/Versions/2.7/bin/virtualenvwrapper_lazy.sh

# function frameworkpython {
#   if [[ ! -z "$VIRTUAL_ENV" ]]; then
#      PYTHONHOME=$VIRTUAL_ENV /usr/local/bin/python "$@"
#   else
#     /usr/local/bin/python "$@"
#   fi
# }

ZSH_THEME="theunraveler"

plugins=(gitfast node)

source $ZSH/oh-my-zsh.sh

alias yt="yarn test"
alias ys="yarn start"
alias ya="yarn add"
alias yad="yarn add --dev"

alias te="code" # te for text editor
alias py="python3"
alias gac="git add . && git commit -m"
alias amend="git commit --amend --no-edit"

alias convert-webm="for i in webm/*.webm; do ffmpeg -i \$i \"\${webm/i%.webm}\".mp4; done"
alias convert-flac="for i in *.flac; do ffmpeg -i $i -ab 320k -map_metadata 0 -id3v2_version 3 "${i%.flac}".mp3; done"

mkto(){
	mkdir $1 && cd $1
}

trash(){
	mv $1 ~/.Trash/$1
}

# clone a git repo, cd into it, npm install and open it in my text editor
nclone() {
	git clone $1 && cd ./*(-/om[1]) && npm install && te .
}

# shortcut for a bunch of steps typical for starting a project using node.js
ninit() {
	mkto $1 && npm init && curl https://www.gitignore.io/api/node,macos > .gitignore && git init && npm i --save-dev mocha chai && touch index.js && touch README.md && git add . && git commit -m "Setup" && te .
}

html-boilerplate(){
	echo -e "<!DOCTYPE html>"
	echo -e "<html lang=\"en\">"
	echo -e "\t<head>"
	echo -e "\t\t<meta charset=\"utf-8\">"
	echo -e "\t\t<meta name=\"viewport\" content=\"width=device-width initial-scale=1.0\">"
	echo -e "\t\t<title>"$1"</title>"
	echo -e "\t</head>"
	echo -e "\t<body>"
	echo -e "\t</body>"
	echo -e "</html>\n"
}

html(){
	html-boilerplate $1 > $1.html && g add $1.html && g commit -m "Created HTML file"
}

# used to have a bunch of shell functions here to create different types of React component, 
# but nowadays I use mkjsx instead
