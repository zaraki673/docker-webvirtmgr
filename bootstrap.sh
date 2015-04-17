#!/bin/sh

if [ ! -f "/var/local/webvirtmgr/webvirtmgr.sqlite3" ]; then

/usr/bin/python /webvirtmgr/manage.py syncdb --noinput
echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', 'admin@localhost', '1234')" | /usr/bin/python /webvirtmgr/manage.py shell

fi

if [ -f /.libvirt_admin_created ]; then
    echo "libvirt 'webvirtmgr' user already created!"
    exit 0
fi

#generate pasword
PASS=${MEMCACHED_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MEMCACHED_PASS} ] && echo "preset" || echo "random" )

echo "=> Creating an admin user with a ${_word} password in Memcached"
echo mech_list: plain > /usr/lib/sasl2/memcached.conf
echo $PASS | saslpasswd2 -a libvirt -c webvirtmgr -p
echo "=> Done"
touch /.libvirt_admin_created

echo "========================================================================"
echo "You can now connect to this Memcached server using:"
echo ""
echo "    USERNAME:webvirtmgr      PASSWORD:$PASS"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo "========================================================================"
