{ ... }:
{
  # backup ssd
  environment.etc."crypttab".text = ''
    backup UUID=0945e618-3ea4-44b9-af26-8edde232fc28 /etc/luks-keys/js-backup nofail
  ''; 
  fileSystems."/mnt/storage/backup" =
    { device = "/dev/mapper/backup";
      fsType = "ext4";
      options = [ "nofail" ];
    };
}