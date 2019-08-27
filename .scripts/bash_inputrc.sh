if [ ! -a ~/.inputrc ]; then
	echo '$include /etc/inputrc' > ~/.inputrc;
fi

echo 'set completion-ignor-case On' >> ~/.inputrc
