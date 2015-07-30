# Vagrant Lumen Dev Box

This Vagrant / Puppet setup provides a lightweight and easily reproducible
development environment for Laravel Lumen.

## Getting Started

After cloning the repository, you need to pull down the submodules. Do this by
running:

```
git submodule init
git submodule update
```

Once they've all come down, you should be able to spin the machine up in the
usual fashion by issuing:

```
vagrant up
```

This will power the box on and initiate the provisioner automatically. When it
finishes, you should be able to access the installed Lumen instance at
[localhost on port 8080](http://localhost:8080).

Your application should be available at www/app-name (default app name is
tutorial).
