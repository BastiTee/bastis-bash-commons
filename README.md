## Basti's Bash Commons
> Personal collection of pure-bash modules and scripts

Feel free to reuse or fork this.

### Integrate into a script 

```
[ "$( which bbc &>/dev/null && echo $? )" != "0" ] && { \
wget http://bit.ly/1XuHtbl -O /tmp/bbc; source /tmp/bbc; rm /tmp/bbc; }
```
