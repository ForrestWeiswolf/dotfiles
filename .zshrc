# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.2

# Path to your oh-my-zsh installation.
export ZSH="/Users/forrestwolf/.oh-my-zsh"

# export PATH="/usr/local/bin/python3:$PATH/"

export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

ZSH_THEME="theunraveler"

plugins=(gitfast node)

source $ZSH/oh-my-zsh.sh

export SAVEHIST=50000
export HISTSIZE=20000


alias py="python3"
alias pullm="git fetch origin main:main"
alias prune="git checkout main && git branch --merged | egrep -v \"(^\*|main|dev)\" | xargs git branch -d"
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

andtrash(){
	$@ && trash $2
	# figure out how to pass this the index of thing to trash?
}

# clone a git repo, cd into it, yarn install and open it in my text editor
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
	&& curl https://www.toptal.com/developers/gitignore/api/node,macos > .gitignore \
	&& git init \
	&& yarn add -D jest typescript ts-jest @types/jest \
	&& npx tsc --init \
	&& mkdir src && mkdir test && touch src/index.ts && touch README.md \
	&& echo "/** @type {import('ts-jest/dist/types').InitialOptionsTsJest} */" >> jest.config.js \
	&& echo "module.exports = {" >> jest.config.js \
	&& echo "		preset: 'ts-jest'," >> jest.config.js \
	&& echo "		testEnvironment: 'node'," >> jest.config.js \
	&& echo "};" >> jest.config.js \
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
	html-boilerplate $1 > $1.html && git add $1.html
}

transcribe(){
	whisper --language English --model base.en --output_format txt $@
}

numeric-rename() {
	local len=${#*[@]}

	local count=0
	if [[  len -gt 0  ]]
	then
		count=$1
	fi

	for i in $(ls -rt); do mv $i $count.${i:e} && count=$((count+1)); done
}

smaller() {
	if [[ $( stat -f %z "$1" ) -lt $( stat -f %z "$2" ) ]]; then echo $1; else echo $2; fi
}

larger() {
	if [[ $( stat -f %z "$1" ) -lt $( stat -f %z "$2" ) ]]; then echo $2; else echo $1; fi
}

move-to-dir() {
	mv $1 $2/${1:t}
}

# a bunch of shortcuts for ffmpeg commands

fcut-name(){
	ffmpeg -ss $2 -to $3 -i $1 -c copy  $4
}

fcut(){
	local len=${#*[@]}

	if [[  len -le 3  ]]
	then
		fcut-name $1 $2 $3 ${1:r}-trimmed.mp4
	fi

	if [[  len -gt 3  ]]
	then
		local count=0
		mkdir ${1:t:r}
		for i in {2..$len..2}; do fcut-name $1 $argv[i] $argv[i+1] ${1:t:r}/${1:t:r}\ $count.mp4 && count=$((count+1)); done
	fi
}

fconv-name(){
	ffmpeg -i $1 -vcodec libx265 -tag:v hvc1 -c:a eac3 -b:a 224k -crf 28 -filter:v $2 -ss $3 -to $4 ${5:r:t}.mp4
}

fconv(){
	local len=${#*[@]}

	if [[  len -le 4  ]]
	then
		fconv-name $1 $2 $3 $4 $1:t
	fi

	if [[  len -gt 4  ]]
	then
		local count=0
		mkdir ${1:t:r}
		for i in {3..$len..2}; do fconv-name $1 $2 $argv[i] $argv[i+1] ${1:t:r}/${1:t:r}\ $count.mp4 && count=$((count+1)); done
	fi
}

fextract(){
	ffmpeg -i $1 -vn -acodec copy ${1:t:r}.aac
}

fprobe() {
	ffprobe -v error -show_entries stream=width,height -of default=noprint_wrappers=1 $1
}

concat-mp3() {
  for var in "$@"
	do
		echo "file './${var:t}'" >> list.txt
	done

	ffmpeg -f concat -safe 0 -i list.txt -c copy combined.mp3
	rm list.txt
}

m4a-convert() {
	mkdir prev
	mkdir output
	local larger
	local smaller
	for i in *.m4a
	do
		ffmpeg -i $i -hide_banner -loglevel error -map_metadata:s:a 0:s:a ${i:r}.mp3\
			&& larger="$(larger $i ${i:r}.mp3)"\
			&& smaller="$(smaller $i ${i:r}.mp3)"\
			&& move-to-dir $larger prev && move-to-dir $smaller output
	done
}
