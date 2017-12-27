To dump the list of currently installed applications:

```
dpkg --get-selections >output-file
```

To re-import:

```
sudo dpkg --set-selections <output-file 
sudo apt-get dselect-upgrade
```
