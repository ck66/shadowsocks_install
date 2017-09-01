#!/bin/bash
 
KernelVer='';
KernelBitVer='';
MainURL='http://kernel.ubuntu.com/~kernel-ppa/mainline'
[ -n "$tmpKernelVer" ] && {
wget -qO /dev/null "$MainURL/$tmpKernelVer"
[ $? -ne '0' ] && echo 'Please input a vaild kernel version! exp: v4.11.9.' && exit 1
KernelVer="$tmpKernelVer"
}
[ -z "$tmpKernelVer" ] && {
KernelVerBIG="$(wget -qO- "$MainURL" |awk -F '/">|href="' '{print $2}' |sed '/rc/d;/^$/d' |tail -n1)"
[ -n "$KernelVerBIG" ] && KernelVer="$(wget -qO- "$MainURL" |awk -F '/">|href="' '{print $2}' |sed '/rc/d;/^$/d' |grep ''${KernelVerBIG}'' |sort -n |tail -n1)"
}
[ -z "$KernelVer" ] && echo 'Error,Get Kernel fail! ' && exit 1
ReleaseURL="$(echo -n "$MainURL/$KernelVer")"
KernelBit="$(getconf LONG_BIT)"
[ "$KernelBit" == '32' ] && KernelBitVer='i386'
[ "$KernelBit" == '64' ] && KernelBitVer='amd64'
[ -z "$KernelBitVer" ] && echo "Error! " && exit 1
HeadersFile="$(wget -qO- "$ReleaseURL" |awk -F '">|href="' '/generic.*.deb/{print $2}' |grep 'headers' |grep "$KernelBitVer" |head -n1)"
[ -n "$HeadersFile" ] && HeadersAll="$(echo "$HeadersFile" |sed 's/-generic//g;s/_'${KernelBitVer}'.deb/_all.deb/g')"
[ -z "$HeadersAll" ] && echo "Error! Get Linux Headers for All." && exit 1
echo "$HeadersFile" | grep -q "$(uname -r)"
[ $? -ne '0' ] && echo "Error! Header not be matched by Linux Kernel." && exit 1
echo -ne "Download Kernel Headers for All\n\t$HeadersAll\n"
wget -qO "$HeadersAll" "$ReleaseURL/$HeadersAll"
echo -ne "Install Kernel Headers for All\n\t$HeadersAll\n"
dpkg -i "$HeadersAll" >/dev/null 2>&1
echo -ne "Download Kernel Headers\n\t$HeadersFile\n"
wget -qO "$HeadersFile" "$ReleaseURL/$HeadersFile"
echo -ne "Install Kernel Headers\n\t$HeadersFile\n"
dpkg -i "$HeadersFile" >/dev/null 2>&1
[ "$1" == '-f' ] && {
echo "It will reboot now..."
} || {
read -n 1 -p "Press Enter to reboot..." INP
if [ "$INP" != '' ] ; then
echo -ne '\b \n'
fi
}
sleep 3 && reboot
