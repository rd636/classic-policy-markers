
# 131_bulk_config_check_wrapper.pl
Tool for bulk use of config_check against a directory of ns.conf files.




# classic-policy-markers
Prefix configuration lines from a ns.conf text configuration file with flags to indicate where classic policies and deprecated commands exist.

```
> shell
# cd /nsconfig
# curl -O https://raw.githubusercontent.com/rd636/classic-policy-markers/master/classic_chk.pl
# chmod 744 classic_chk.pl
# classic_chk.pl ns.conf
ns.conf is 354 lines.
ns.conf.audit.conf has 1 classic configuration commands.
# cat ns.conf.audit.conf | grep '>>>'
>>> add authentication localPolicy true ns_true
# nspepi -e ns_true
"TRUE"
#
```
