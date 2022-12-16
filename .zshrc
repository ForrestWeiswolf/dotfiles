# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/forrest/.oh-my-zsh


# export PATH="/anaconda3/bin:$PATH/"

export PATH="/usr/local/bin/python3:$PATH/"

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

alias py="python3"
alias pullm="git fetch origin main:main"
alias prune="git checkout master && git branch --merged | egrep -v \"(^\*|master|dev)\" | xargs git branch -d"
alias bell="print -n \"\a\""

mkto(){
	mkdir $1 && cd $1
}

trash-item(){
  local NAME=$(basename $1);  if [ -e ~/.Trash/$NAME ]
  then
    local TIME=$(date +"%H.%M.%S");
    NAME="$NAME $TIME";
    mv $1 ~/.Trash/$NAME;
  else
    mv $1 ~/.Trash/$NAME
  fi
}

trash(){
  for var in "$@"
  do
      trash-item "$var"
  done
}

# clone a git repo, cd into it, npm install and open it in my text editor
nclone() {
	git clone $1 && cd ./*(-/om[1]) && yarn install && code .
}

# shortcut for a bunch of steps typical for starting a project using node.js
ninit() {
	mkto $1 && yarn init \
	&& curl -sL https://www.toptal.com/developers/gitignore/api/node,macos > .gitignore \
	&& git init \
	&& yarn add -D jest \
	&& touch index.js && touch README.md \
	&& git add . && git commit -m "Setup" && git branch -M main && code .
}

# like ninit but with typescript
tinit() {
	mkto $1 && yarn init \
	&& curl -sL https://www.toptal.com/developers/gitignore/api/node,macos > .gitignore \
	&& git init \
	&& yarn add -D jest typescript \
	&& npx tsc --init \
	&& mkdir src && mkdir test && touch src/index.ts && touch README.md \
	&& git add . && git commit -m "Setup" && git branch -M main && code .
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

fcut-name(){
	ffmpeg -i $1 -c copy -ss $2 -to $3 $4
}

fcut(){
	fcut-name $1 $2 $3 $4 ${1:r}-trimmed.mp4
}

fcut-multi(){
	local len=${#*[@]}
	local count=0
	mkdir ${1:r}
	for i in {3..$len..2}; do fcut-name $1 $argv[i] $argv[i+1] ${1:r}/$count.mp4 && count=$((count+1)); done
}

fconv-name(){
	ffmpeg -i $1 -vcodec libx265 -tag:v hvc1 -c:a eac3 -b:a 224k -crf 28 -filter:v $2 -ss $3 -to $4 $5
}

fconv(){
	fconv-name $1 $2 $3 $4 $1:t
}

fconv-multi(){
	local len=${#*[@]}
	local count=0
	mkdir ${1:r}
	for i in {3..$len..2}; do fconv-name $1 $2 $argv[i] $argv[i+1] ${1:r}/$count.mp4 && count=$((count+1)); done
}

transcribe(){
	vosk-transcriber -i $1 -o ${1:r}.txt
}
