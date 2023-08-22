# ALAZIF Mincraft Server Environment - How to use
## Explain:
When using the server command, attach with the following command.

## Prior knowledge:
This suite of tools is based on "screen","systemd" and "ufw".
Therefore, it inherits these operations.
"Confname" serves as the destination for commands to act on.
### example
When working with live.conf. - live
or test                      - test

## Running Server CLI:
sudo -u [username] screen -r mc[confname]
### or
screen -r mc[confname]

Press C-a,C-d to exit the server screen.
Check the "screen" command for other operations.

## Server backup:
When reload is executed, it will automatically stop after
executing the all-save command, and then save the world
data backup. It will automatically reboot after saving.

## Save file location:
./[confname]/world_backup/

## Daemon Server control:
sudo systemctl [start | stop | reload | status] minecraft

## Systemd register:
sudo systemctl [enable | disable] minecraft

##Systemd unit file location:
/etc/systemd/system/minecraft-[confname].server
