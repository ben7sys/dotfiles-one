# IP route für Synogard
ip route get 192.168.77.77
ip route add 192.168.77.0/24 via 10.0.10.1 dev enp5s0
ip route delete 192.168.77.0/24 dev enp5s0

## IP route mit Unit-File:
/home/sieben/.dotfiles/etc/systemd/system/add-static-route.service

# Mit diesem Befehl können systemd unit files nach system gelinkt werden:
cd /etc/systemd/system
sudo ln -s /home/sieben/.dotfiles/etc/systemd/system/add-static-route.service add-static-route.service

## Link aus irgendeinem anderen Verzeichnis:
sudo ln -s /home/sieben/.dotfiles/etc/systemd/system/add-static-route.service /etc/systemd/system/add-static-route.service
