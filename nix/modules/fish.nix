{ ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      nixup = "sudo darwin-rebuild switch --flake ~/.config/nix";
      cl = "clear";
      n = "nvim";
      g = "lazygit";
    };
    interactiveShellInit = ''
      # Persistent ssh-agent for Git SSH signing (1Password handles github.com separately).
      # ssh-add -l: 0 = keys present, 1 = empty but alive, 2 = cannot connect.
      set -gx SSH_AUTH_SOCK $HOME/.ssh/agent.sock
      ssh-add -l >/dev/null 2>&1
      switch $status
        case 0
          # Agent already has keys
        case 1
          ssh-add --apple-use-keychain $HOME/.ssh/id_ed25519 2>/dev/null
        case 2
          rm -f $SSH_AUTH_SOCK
          eval (ssh-agent -a $SSH_AUTH_SOCK -c)
          ssh-add --apple-use-keychain $HOME/.ssh/id_ed25519 2>/dev/null
      end

      if test -x /opt/homebrew/bin/brew
        eval "$(/opt/homebrew/bin/brew shellenv)"
      end

      # pnpm (optional)
      set -gx PNPM_HOME $HOME/Library/pnpm
      if test -d $PNPM_HOME; and not string match -q -- $PNPM_HOME $PATH
        set -gx PATH $PNPM_HOME $PATH
      end
      fish_add_path $HOME/.local/bin
      fish_add_path $HOME/.config/bin
    '';
  };
}
