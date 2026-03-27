class InputField {
  float x, y, w, h;
  String text = "";
  boolean active = false;
  String placeholder;

  InputField(float x, float y, float w, float h, String placeholder) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.placeholder = placeholder;
  }

  void display() {
    stroke(active ? color(0, 120, 255) : 0);
    fill(255);
    rect(x, y, w, h, 5);
    fill(text.length() == 0 ? 150 : 0);
    text(text.length() == 0 ? placeholder : text, x + 5, y + 22);
  }

  void handleClick(float mx, float my) {
    active = (mx > x && mx < x + w && my > y && my < y + h);
  }

  void keyTyped(char k) {
    if (!active) return;
    if (k == BACKSPACE) {
      if (text.length() > 0) text = text.substring(0, text.length()-1);
    } else if (k != ENTER && k != RETURN) {
      text += k;
    }
  }
}
