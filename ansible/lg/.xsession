if [[ ! -e $HOME/.config/i3/config ]]
then
    i3-config-wizard -m win
    echo "exec looking-glass-client" >> $HOME/.config/i3/config
fi
exec i3
