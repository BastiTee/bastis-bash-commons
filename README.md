## Basti's Bash Commons
> Personal collection of pure-bash modules and scripts

Feel free to reuse or fork this.

### Integrate into a script 

```shell
# If bbc-script is not available on path
# then download it to temp, source it and clean up
# otherwise just source it. 

[ "$( which bbc &>/dev/null && echo $? )" != "0" ]\
&& { wget http://bit.ly/1XuHtbl -O /tmp/bbc; source /tmp/bbc; rm /tmp/bbc; }\
|| source bbc
```
