{
  programs.wofi = {
    enable = true;
    settings = {
      show = "drun";
      prompt = "❯";
      insensitive = true;
      allow_markup = false;
      location = "center";
      width = 500;
      height = 300;
      columns = 1;
      allow_images = true;
    };
  };
}
