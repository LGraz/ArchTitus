#! /bin/bash

# backup and update config files
    # copy dirs from "$CDIR" to "$HOME/.config/"
    CDIR=$HOME/ArchTitus/configs/config_files/
    timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    backup_dir="$HOME/.config/conf_backups/backup_$timestamp"
    mkdir -p $backup_dir

    # for dir in redshift dunst i3 i3blocks rofi scripts sound bluetooth terminator nano picom.conf; do
    for dir in `ls --almost-all $CDIR/config_dirs/`; do
    echo "removing and linking the director: $HOME/.config/$dir"
    mv $HOME/.config/${dir} $backup_dir
    ln -rs ${CDIR}/config_dirs/${dir} $HOME/.config/
    done

    # copy all files from "$CDIR/homedir" to "$HOME/"
    mkdir -p $backup_dir/homedir
    for f in `ls --almost-all $CDIR/homedir/`; do
    echo "removing and linking the file: $f"
    mv $HOME/$f $backup_dir/homedir
    ln -rs ${CDIR}/homedir/$f $HOME/$f
    done

# update crontabs
crontab $HOME/.cronjobs
