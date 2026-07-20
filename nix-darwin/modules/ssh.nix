{ config, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      # Git uses git@github.com (and sometimes ssh.github.com:443). Only those use 1Password.
      # Path must be quoted in SSH config (contains space in "Group Containers").
      "github.com ssh.github.com" = {
        identityAgent = [ "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"" ];
      };

      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };
  };

  # Start ssh-agent and add key in every new terminal so Git SSH signing works
  # without running eval (ssh-agent -c) and ssh-add manually.
  programs.fish = {
    enable = true;
    shellAliases = {
      nixup = "sudo darwin-rebuild switch --flake ~/.config/nix-darwin";
      cl = "clear";
      n = "nvim";
      lg = "lazygit";
    };
    functions = {
      __notify_long_command = {
        body = ''
          set threshold 60000
          if test $CMD_DURATION -gt $threshold
            set elapsed (math -s3 "$CMD_DURATION / 1000")
            if test (uname) = Darwin
              osascript -e "display notification \"Finished in $elapsed seconds\" with title \"Command Completed\""
            else if type -q notify-send
              notify-send "Command Completed" "Finished in $elapsed seconds"
            end
          end
        '';
        onEvent = "fish_postexec";
      };
    };
    interactiveShellInit = ''
      # Single persistent ssh-agent (shared across terminals) for Git SSH signing.
      # ssh-add -l: 0 = keys present, 1 = agent empty but alive, 2 = cannot connect (stale/missing socket).
      # Do not spawn a second agent on exit 1 — that hits "Address already in use" on the same socket.
      set -gx SSH_AUTH_SOCK $HOME/.ssh/agent.sock
      ssh-add -l >/dev/null 2>&1
      switch $status
        case 0
          # Agent already has keys
        case 1
          ssh-add --apple-use-keychain $HOME/.ssh/id_ed25519
        case 2
          rm -f $SSH_AUTH_SOCK
          eval (ssh-agent -a $SSH_AUTH_SOCK -c)
          ssh-add --apple-use-keychain $HOME/.ssh/id_ed25519
      end

      eval "$(/opt/homebrew/bin/brew shellenv)"
      zoxide init fish | source

      # pnpm
      set -gx PNPM_HOME /Users/sathira/Library/pnpm
      if not string match -q -- $PNPM_HOME $PATH
        set -gx PATH "$PNPM_HOME" $PATH
      end
      fish_add_path $HOME/.local/bin
      fish_add_path $HOME/.config/bin

      # So `toggle-appearance` can sync all Neovim instances (nvim --serverlist)
      set -gx NVIM_LISTEN_ADDRESS $HOME/.local/share/nvim/nvim.sock
    '';
  };
}
