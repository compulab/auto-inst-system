NORMAL="\033[0m"
GREEN="\033[32;1m"

title() {
	echo -e "${GREEN}===${1}===${NORMAL}"
}

announce() {
	echo -e "${GREEN}* ${NORMAL}${@}"
}
