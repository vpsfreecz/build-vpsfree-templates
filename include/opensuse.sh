#!/bin/bash
require_cmd zypper

if [ "$SPIN" == "leap" ]; then
	REPOSITORY=http://download.opensuse.org/distribution/leap/$SPINVER/repo/oss/
	UPDATES=http://download.opensuse.org/update/leap/$SPINVER/oss/
elif [ "$SPIN" == "tumbleweed" ]; then
	REPOSITORY=http://download.opensuse.org/tumbleweed/repo/oss/
	UPDATES=http://download.opensuse.org/update/tumbleweed/
else
	fail "unsupported spin"
fi

EXTRAPKGS='vim iproute2 iputils net-tools procps less psmisc timezone aaa_base-extras openssh'

ZYPPER="zypper -v --root=$INSTALL --non-interactive --gpg-auto-import-keys "

function bootstrap {
	set -e
	$ZYPPER addrepo --refresh -g $REPOSITORY openSUSE-oss
	$ZYPPER addrepo --refresh -g $UPDATES openSUSE-updates
	$ZYPPER refresh
	$ZYPPER install --no-recommends aaa_base shadow
	$ZYPPER install --no-recommends patterns-base-base patterns-base-sw_management
	$ZYPPER install $EXTRAPKGS
	set +e

}

function configure-opensuse {
	configure-append <<EOF
[ ! -e /sbin/init ] && ln -sf /bin/systemd /sbin/init
systemctl enable  wicked.service
usermod -L root
systemctl enable sshd.service
systemctl mask systemd-udev-trigger.service
systemctl mask systemd-modules-load.service
echo console >> /etc/securetty
sed -i 's/#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=900s/' /etc/systemd/system.conf
echo "%_netsharedpath /sys:/proc" >> /etc/rpm/macros.vpsadminos
mkdir -p /var/log/journal
EOF
}
