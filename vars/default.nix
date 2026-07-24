{ lib }:
rec {
  username = "suiluj";

  naming-schema = name: "js-${name}";
  domain = "jschuchert.de";

  paths = rec {
    home = "/home/${username}";
    storage = "/mnt/storage";
    js = "${storage}/JS";
    documents = "${js}/documents";
    system = "${documents}/system";
    nixos = "${system}/nixos";
    nixosData = "${system}/nixos/data";
    data = "${system}/data";
    browser = "${system}/data/browser";
    templates = "${nixosData}/templates";
    zmk = "${documents}/projects/hardware/keyboards/zmk/zmk-config";
  };
  ips = {
    prefix = "192.168.178.";
    tower = "192.168.178.36"; # not stable
    laptop = "192.168.178.42"; # not stable
    home = "192.168.1.1";
    server = "192.168.178.131";
  };
}