{ config, ... }:

{
  boot = {  
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 1;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        # useOSProber = true;
        extraEntries = "
          menuentry 'systemd-boot' {
            insmod part_gpt
            insmod fat
            insmod chain
            search --no-floppy --fs-uuid --set=root 86BE-3516
            chainloader /EFI/systemd/systemd-bootx64.efi
          }
          menuentry 'Windows Boot Manager (on /dev/nvme0n1p1)' --class windows --class os $menuentry_id_option 'osprober-efi-86BE-3516' {
            insmod part_gpt
            insmod fat
            search --no-floppy --fs-uuid --set=root 86BE-3516
            chainloader /EFI/Microsoft/Boot/bootmgfw.efi
          }
        ";
        gfxmodeEfi = "2560x1440";
      };
    };

    plymouth = {
      enable = true;
      theme = "text";
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
}