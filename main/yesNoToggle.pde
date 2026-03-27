class YesNoToggle {
  float x, y;
  String label;
  boolean yes = false;
  boolean no = true; // default

  YesNoToggle(float x, float y, String label) {
    this.x = x;
    this.y = y;
    this.label = label;
  }

  void display() {
    // YES box
    fill(yes ? color(0, 160, 80) : 230);
    rect(x, y, 50, 30, 5);
    fill(yes ? 255 : 0);
    text("YES", x + 12, y + 20);

    // NO box
    fill(no ? color(200, 60, 60) : 230);
    rect(x + 60, y, 50, 30, 5);
    fill(no ? 255 : 0);
    text("NO", x + 75, y + 20);

    // Label
    fill(0);
    text(label, x + 130, y + 20);
  }

  void handleClick(float mx, float my) {
    // YES clicked
    if (mx > x && mx < x + 50 && my > y && my < y + 30) {
      yes = true;
      no = false;
    }

    // NO clicked
    if (mx > x + 60 && mx < x + 110 && my > y && my < y + 30) {
      yes = false;
      no = true;
    }

    // Label clicked → explanation
    if (mx > x + 130 && mx < x + 350 && my > y && my < y + 30) {
      selectedExplanation = getExplanation(label);
    }
  }

  boolean isYes() {
    return yes;
  }
}
