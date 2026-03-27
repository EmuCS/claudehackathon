// ==========================
// Screen Base Class
// ==========================

abstract class Screen {
  ArrayList<Widget> widgets;
  
  Screen() {
    widgets = new ArrayList<Widget>();
    addHomeButton();
  }
  
  void addHomeButton() {
    // Only add home button if not the home screen itself
    if (!(this instanceof HomeScreen)) {
      Widget homeBtn = new Widget(10, 10, 80, 30, "Home", () -> {
        currentScreen = homeScreen;
      });
      widgets.add(homeBtn);
    }
  }
  
  void displayWidgets() {
    for (Widget w : widgets) {
      w.display();
    }
  }
  
  abstract void display();
  void mousePressed() {
    for (Widget w : widgets) {
      if (w.isClicked(mouseX, mouseY)) {
        w.onClick();
      }
    }
  }
  
  void mouseDragged() {
  // Override in subclasses if needed
  }
  
  void mouseScrolled(float amount) 
  {
  // Default: do nothing
  }
}

// ==========================
// Home Screen
// ==========================
class HomeScreen extends Screen {

  HomeScreen() {
    super();
    Widget taxExplainerBtn = new Widget(300, 200, 200, 50, "How to: Taxes", () -> {
                        currentScreen = taxExplainer;
                        });
    widgets.add(taxExplainerBtn);
    // Add buttons for other screens
    Widget payslipBtn = new Widget(300, 300, 200, 50, "Payslip Calculator", () -> {
                        currentScreen = payslipScreen;
                        });
    widgets.add(payslipBtn);


    
    // You can add more buttons for future screens here
  }

  void display() {
    background(0);
    fill(textGreen);
    textSize(32);
    textAlign(CENTER);
    textFont(headingFont);
    text("taxÉIRE", width/2, 100);
    
    // Display buttons
    displayWidgets();
  }
}

// ==========================
// Payslip Calculator Screen
// ==========================
class PayslipCalculatorScreen extends Screen {
  
  PayslipCalculatorScreen() {
    super();
    // Add more input fields and widgets later
  }
  
  void display() {
    background(backgroundBlack);
    fill(textGreen);
    textSize(28);
    textAlign(CENTER);
    textFont(headingFont);
    text("Payslip Calculator Screen", width/2, 100);
    
    // Placeholder for input fields
    fill(buttonWhite);
    rect(250, 200, 300, 50);
    fill(textGreen);
    textAlign(LEFT, CENTER);
    text("Gross Salary Input (placeholder)", 260, 225);
    
    displayWidgets();
  }
}




// taxEplainer Screen
// ==========================
class TaxExplainerScreen extends Screen
{
  float scrollY = 0; // Current scroll position
  float boxY = 150; // Y position of the text box
  float boxW = width - 50; // Width of the text box
  float boxH = height - 150 - 50; // Height of the text box
  float totalTextHeight = 0;
  String[] mdLines;
  
  TaxExplainerScreen()
  {
    super();
    mdLines = loadStrings("TaxExplainerText.md");
  }
  
   void display() 
   {
     background(backgroundBlack);
     fill(textGreen);
     textSize(28);
     textAlign(CENTER);
     textFont(headingFont);
     text("How to: Taxes", width/2, 100);
     
     fill(backgroundBlack);
     stroke(255);
     rect((width - boxW) / 2, boxY, boxW, boxH);
     
     drawScrollableText();
    // Draw scrollbar
     drawScrollbar();

     displayWidgets();
   }
   
   void drawScrollableText() 
   {
    float boxLeft = (width - boxW) / 2;
    float x = boxLeft + 20;
    float y = boxY + 20 - scrollY;
    float usableWidth = boxW - 40;
  
    final float LINE_HEIGHT = 26;
    final float HEADING_HEIGHT = 34;
    final float BULLET_INDENT = 20;
  
    pushMatrix();
    clip(boxLeft, boxY, boxW + 10, boxH);    
    textAlign(LEFT, TOP);
  
    for (String raw : mdLines) {
  
      String line = raw.trim();
      fill(textGreen);
      // -------------------------
      // HEADINGS
      // -------------------------
      if (line.startsWith("# ")) {
        textFont(headingFont);
        textSize(24);
        text(line.substring(2), x, y);
        y += HEADING_HEIGHT;
        continue;
      }
  
      // -------------------------
      // BULLET POINTS
      // -------------------------
      if (line.startsWith("- ")) {
  
        textFont(basicFont);
        textSize(18);
  
        String bulletText = line.substring(2).trim();
  
        // Draw bullet
        text("•", x, y);
  
        // Wrapped bullet text starts indented
        float textX = x + BULLET_INDENT;
        String[] words = split(bulletText, ' ');
        String current = "";
  
        for (String w : words) {
          String test = current + w + " ";
          if (textWidth(test) > usableWidth - BULLET_INDENT) {
            text(current, textX, y);
            y += LINE_HEIGHT;
            current = w + " ";
          } else {
            current = test;
          }
        }
  
        // Draw final line
        text(current, textX, y);
        y += LINE_HEIGHT;
        continue;
      }
  
      // -------------------------
      // NORMAL TEXT (wrapped)
      // -------------------------
      textFont(basicFont);
      textSize(18);
  
      String[] words = split(line, ' ');
      String current = "";
  
      for (String w : words) {
        String test = current + w + " ";
        if (textWidth(test) > usableWidth) {
          text(current, x, y);
          y += LINE_HEIGHT;
          current = w + " ";
        } else {
          current = test;
        }
      }
  
      text(current, x, y);
      y += LINE_HEIGHT;
    }
  
    noClip();
    popMatrix();
  
    // -------------------------
    // UPDATE TOTAL CONTENT HEIGHT
    // -------------------------
    totalTextHeight = y - (boxY + 20);
  }



  void drawScrollbar() {
    // Calculate scrollbar height based on content
    float scrollbarX = (width - boxW) / 2 + boxW - 15;
    float scrollbarW = 10;
    float scrollbarH = map(boxH, 0, 1000, boxH, 50); // Adjust 1000 to your total text height
    float scrollbarY = boxY + map(scrollY, 0, 500, 0, boxH - scrollbarH); // Adjust 500 to max scroll
    
    // Draw scrollbar track
    fill(200);
    rect(scrollbarX, boxY, scrollbarW, boxH);

    // Draw scrollbar thumb
    fill(150);
    rect(scrollbarX, scrollbarY, scrollbarW, scrollbarH);
  }

  void mouseDragged() {
    // Check if mouse is over scrollbar
    float scrollbarX = (width - boxW) / 2 + boxW - 15;
    if (mouseX > scrollbarX && mouseX < scrollbarX + 10 && mouseY > boxY && mouseY < boxY + boxH) {
      // Update scroll position
      scrollY = map(mouseY, boxY, boxY + boxH, 0, 500); // Adjust 500 to max scroll
      scrollY = constrain(scrollY, 0, 500); // Clamp to max
    }
  }
  
  void mouseScrolled(float amount) 
  {
    scrollY += amount * 20;  // adjust speed
    scrollY = constrain(scrollY, 0, 500); // temporary max scroll
  }

}
