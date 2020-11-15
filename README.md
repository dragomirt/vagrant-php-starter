# Vagrant PHP Boilerplate
Have you ever been such a situation where you have to start working on a project ASAP, but Homestead is, as usually, not loading, and building the box by yourself is too time, consuming? **You've come to the right place!**

This setup contains:
- Debian 10
- PHP 7.3
- Composer
- MySQL 5.8
- Redis
- Imagick
- Apache 2
- Configured dpkg
- nfs
- htaccess support
- and much more!

Fell free to download and try it out!
If you have any suggestion, please let me know ;)

### How to use?

```
git pull https://github.com/dragomirt/vagrant-php-starter.git
cd vagrant-php-starter
vagrant up
```

And in a couple of minutes, you are ready to work on the project!
Default address is `192.168.33.10`

### Known bugs
- On systems with guest access or multiple accounts, nfs sync might not work normally. In case of problems with file storage, switch back to rsync, by replacing line 12 with
`config.vm.synced_folder ".", "/var/www/html", :owner => 'www-data', :group => 'www-data'`

