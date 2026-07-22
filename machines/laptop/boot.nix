{ inputs, config, ...}:

{
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      timeout = 1;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        #useOSProber = true;
        extraEntries = "
          #custom
          menuentry 'Fedora' --class gnu-linux --class gnu --class os $menuentry_id_option 'fedora' {
            # search --no-floppy --fs-uuid --set=root 604cc373-37c7-4121-a8d7-5b3f8d9860fc
            # configfile /grub2/grub.cfg
            #doesn't work because fedora uses fancy script to load entries

            insmod part_gpt
            insmod fat
            search --no-floppy --fs-uuid --set=root D404-FBCE
            chainloader /EFI/fedora/shimx64.efi
          }
          menuentry 'Windows Boot Manager (on /dev/nvme0n1p1)' --class windows --class os $menuentry_id_option 'osprober-efi-D404-FBCE' {
            insmod part_gpt
            insmod fat
            search --no-floppy --fs-uuid --set=root D404-FBCE
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
        ";
      };
    };

    plymouth = {
      enable = true;
    };
    initrd = {
      verbose = false;
      systemd.enable = true;
    };
    consoleLogLevel = 3;
    kernelParams = [
      "quiet"
      "splash"
    ];
  };
  catppuccin.plymouth.enable = true;
}