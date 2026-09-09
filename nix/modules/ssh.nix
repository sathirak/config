{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    # RFC 42 settings (OpenSSH directive names). Replaces deprecated matchBlocks.
    settings = {
      # GitHub only — 1Password agent (path must be quoted: space in "Group Containers").
      "github.com ssh.github.com" = {
        IdentityAgent = [
          "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
        ];
      };

      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
}
