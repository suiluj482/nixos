{ myVars }:

{
  home = conf: { 
    home-manager.users.${myVars.username} = conf;
  };
  homeContext = conf: {
    home-manager.users.${myVars.username} = { config, ... }: conf { inherit config; };
  };
}