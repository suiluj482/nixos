{ config, lib, pkgs, username, home, ... }:

{
    services.openssh = {
        enable = true;
        settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
        };
    };
    users.users."${username}".openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCTpp9c34ihNay4FR1JLhSUzj8s9p5bO7TOa79GGSEmq295MflgcJTZCWu3HwTmjaDT4Czw+gdfXqV723qL44EGo6ffV2CZZ+3Nb2GMCaUmYyqjj3dC0ZRMDkSpmjitfJSCtx1YR7/EtBZflruPz+QHBOswLFtXjzYb8AziDlEPbPkVPtJ+PFC4slRLgBqcRRpqefKkbl99B/fa8mTqULbyQIpo58b7W9OWlrMBe+MpjF1vss1h8NbiYB80hgGIPStK1OKJFZFKqkkaN8HbL6lsJ7JGVdYV3yYn2i050pKxv+QpIh1YwVboWrtHYmC9jveb9fIKbSJfBODqeMuN24YYHSZv3UQseZIR6o6k9TFVosKE39bzTb9vPwMqLqnWVZeIbtPrbxKOyZNafhTu5HHGGJO/q170kgPNgnguiyJ5XnLSIH9Di9t4R240y4/1/GxnO2zkr+WhAuSocd/tMzNdRvqWqSEAxhe1rlutSWGXv7tEaJcCronL2K/JRGaNIrU= suiluj@js"
    ];
}
# } //
# home {
#     home = {
#         file = {
#             ".ssh" = {
#                 source = lib.file.mkOutOfStoreSymlink ../../data/dotfiles/.ssh;
#             };
#         };
#     };
# }