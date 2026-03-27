class YesNoToggles {
  float x, y;
  String label;
  boolean yes = false;
  boolean no  = true;

  // dynamic sizing
  float boxW, boxH, spacing;

  YesNoToggles(float x, float y, String label) {
    this.x = x;
    this.y = y;
    this.label = label;

    updateSize();
  }

  void updateSize() {
    boxW = width * 0.06;
    boxH = height * 0.04;
    spacing = width * 0.01;
  }

  void display() {
    updateSize();

    // YES box
    fill(yes ? color(0,160,80) : 230);
    rect(x, y, boxW, boxH, 6);
    fill(yes ? 255 : 0);
    textSize(boxH * 0.5);
    text("YES", x + boxW * 0.2, y + boxH * 0.7);

    // NO box
    float noX = x + boxW + spacing;

    fill(no ? color(200,60,60) : 230);
    rect(noX, y, boxW, boxH, 6);
    fill(no ? 255 : 0);
    text("NO", noX + boxW * 0.25, y + boxH * 0.7);

    // LABEL (dynamic position)
    float labelX = noX + boxW + spacing * 2;

    fill(30, 80, 200);
    textSize(height * 0.022);
    text(label, labelX, y + boxH * 0.7);

    // underline
    float labelWidth = textWidth(label);
    stroke(30, 80, 200);
    line(labelX, y + boxH * 0.85, labelX + labelWidth, y + boxH * 0.85);
    noStroke();

    // info icon
    float iconX = labelX + labelWidth + spacing;
    float iconSize = boxH * 0.6;
    
    // Prevent icon drifting off-screen
    iconX = min(iconX, width - boxH);

    fill(30, 80, 200);
    ellipse(iconX, y + boxH * 0.5, iconSize, iconSize);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(iconSize * 0.7);
    text("i", iconX, y + boxH * 0.5);

    textAlign(LEFT, BASELINE);
  }

  void handleClick(float mx, float my) {
    float noX = x + boxW + spacing;
    float labelX = noX + boxW + spacing * 2;
    float labelWidth = textWidth(label);
    float iconX = labelX + labelWidth + spacing;

    // YES
    if (mx > x && mx < x + boxW && my > y && my < y + boxH) {
      yes = true;
      no = false;
    }

    // NO
    if (mx > noX && mx < noX + boxW && my > y && my < y + boxH) {
      yes = false;
      no = true;
    }

    // LABEL click
    if (mx > labelX && mx < labelX + labelWidth &&
        my > y && my < y + boxH) {
      openInfo();
    }

    // ICON click
    float d = dist(mx, my, iconX, y + boxH * 0.5);
    if (d < boxH * 0.3) {
      openInfo();
    }
  }

  void openInfo() {
    infoBoxTitle = label;
    infoBoxText  = getExplanation(label);
    showInfoBox  = true;
  }

  boolean isYes() {
    return yes;
  }
  float getRightEdge() {
    float noX = x + boxW + spacing;
    float labelX = noX + boxW + spacing * 2;
    return labelX + textWidth(label) + spacing * 3;
  }
}
