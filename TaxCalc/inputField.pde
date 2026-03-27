class InputField {
  float x, y, w, h;
  String text = "";
  String placeholder;
  boolean active = false;

  InputField(float x, float y, float w, float h, String placeholder) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.placeholder = placeholder;
  }

  void display() {
    stroke(active ? color(0,120,255) : 150);
    fill(255);
    rect(x, y, w, h, 8);

    fill(0);
    text(text.length() == 0 ? placeholder : text, x + 5, y + h * 0.7);
  }

  void mousePressed() {
    active = (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h);
  }

  void keyTyped(char k) {
    if (!active) return;

    if (k == BACKSPACE && text.length() > 0) {
      text = text.substring(0, text.length()-1);
    } else if (k != ENTER && k != RETURN) {
      text += k;
    }
  }
}
