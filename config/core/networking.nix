{ config, pkgs, system-name, ...}:

{
  networking = {
    hostName = system-name;

    networkmanager = {
      enable = true;
      wifi.macAddress = "random";
    };
  };

  # ## dns experimental

  # networking = {
  #   networkmanager.dns = "none";

  #   nameservers = [ "127.0.0.1" "::1" ];
  #   # If using dhcpcd:
  #   dhcpcd.extraConfig = "nohook resolv.conf";

  #   resolvconf.enable = false;
  # };

  # # https://nixos.wiki/wiki/Encrypted_DNS
  # services.dnscrypt-proxy2 = {
  #   enable = true;
  #   # Settings reference:
  #   # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
  #   settings = {
  #     # ipv6_servers = true;
  #     # require_dnssec = true;
  #     # require_nolog = true;
  #     # # Add this to test if dnscrypt-proxy is actually used to resolve DNS requests
  #     # # query_log.file = "/var/log/dnscrypt-proxy/query.log";
  #     # sources.public-resolvers = {
  #     #   urls = [
  #     #     "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
  #     #     "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
  #     #   ];
  #     #   cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
  #     #   minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";


  #     # # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
  #     # # server_names = [ ... ];
      
  #     ipv4_servers = true;
  #     ipv6_servers = true;
  #     require_dnssec = true;
  #     require_nolog = true;
  #     server_names = [ "cloudflare" ]; # or any server from the DNSCrypt list
  #     listen_addresses = [ "127.0.0.1:53" ];

  #     # # only in extra files?
  #     # cloaking
  #     # forwarding_rules = [
  #     #   "jstest.de jschuchert.de"
  #     # ]
  #     # cache_size = 4096;
  #     # cache_min_ttl = 2400;
  #     # cache_max_ttl = 86400;
  #     # cache_neg_min_ttl = 60;
  #     # cache_neg_max_ttl = 600;
  #   };
  # };
}