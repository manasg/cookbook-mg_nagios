Throwaway keys generated to test check_by_ssh

```
ssh-keygen -t rsa -f ./noface.rsa -C nofae@fake
```

If setup correctly, from your mac, you should be able to SSH

```
ssh -i noface.rsa noface@172.28.128.3
```
