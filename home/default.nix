{ pkgs, ... }:

{
  home.packages = with pkgs; [ fish qt5.qtbase nerd-fonts.jetbrains-mono ];

  programs.fish.enable = true;
  programs.fish.defaultShell = true;

  programs.git = {
    enable = true;
    userName = "Rahul Nadagoud";
    userEmail = "nadagoud@pm.me";
  };
}
