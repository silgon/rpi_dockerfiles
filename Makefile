MOUNT_PATH="remote"
RSYNC_COMMAND=rsync -avz --delete --exclude-from=.rsyncignore . ${SERVER_PATH}

.PHONY=check-server-path mount umount sync autosync

mount: check-server-path
	mkdir ${MOUNT_PATH} && sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 ${SERVER_PATH} ${MOUNT_PATH}

umount:
	fusermount -u ${MOUNT_PATH} && rm -r ${MOUNT_PATH}

sync: check-server-path
	${RSYNC_COMMAND}

autosync: sync
	while inotifywait -r -e modify,create,delete .; do \
	${RSYNC_COMMAND} ; \
	done

check-server-path:
ifndef SERVER_PATH
    $(error SERVER_PATH is undefined)
endif
