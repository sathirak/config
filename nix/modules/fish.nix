{ ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      cl = "clear";
      n = "nvim";
      g = "lazygit";
    };
    interactiveShellInit = ''
      if test -x /opt/homebrew/bin/brew
        eval "$(/opt/homebrew/bin/brew shellenv)"
      end

      set -gx PNPM_HOME $HOME/Library/pnpm
      if test -d $PNPM_HOME; and not string match -q -- $PNPM_HOME $PATH
        set -gx PATH $PNPM_HOME $PATH
      end
      fish_add_path $HOME/.local/bin
      fish_add_path $HOME/.config/bin
    '';
  };
}
