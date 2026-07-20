{
  config,
  pkgs,
  ...
}:
let
  jdk = pkgs.javaPackages.compiler.openjdk25;
in
{
  home.packages = with pkgs; [
    # JDK 25 - for Spring Boot and modern Java
    jdk
    # Build tools commonly used with Spring Boot
    maven
    gradle
  ];

  home.sessionVariables = {
    JAVA_HOME = "${jdk}";
  };
}
