Домашние задания по курсу "Дизайн сетей ЦОД"

Для построения сети будет использоваться Cumulus Linux. ВМ будут разворачиваться при помощи Vagrant + libvirt.
Для соединений между ВМ используются порты на хосте 8000-8300, 9000-9300.

Основная часть ВМ описана в Vagrantfile_main.rb. В директориях с номером задания лежат скрипты и Vagrantfile для запуска.

Для подключения по ssh к серверу с libvirt нужно положить рядом с Vagrantfile_main.rb файл с именем Vagrant_ssh.rb с содержимым вида

```ruby
Vagrant.configure("2") do |config|
    config.vm.provider :libvirt do |libvirt|
      libvirt.host = "host_ip"
      libvirt.username = "username"
      libvirt.connect_via_ssh = true
      libvirt.id_ssh_key_file = "path_to_keyfile"
    end
end
```
