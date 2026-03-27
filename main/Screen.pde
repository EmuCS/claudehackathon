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
}

// ==========================
// Home Screen
// ==========================
class HomeScreen extends Screen {

  HomeScreen() {
    super();
    // Add buttons for other screens
    Widget payslipBtn = new Widget(300, 200, 200, 50, "Payslip Calculator", () -> {
      currentScreen = payslipScreen;
    });
    widgets.add(payslipBtn);
    
    // You can add more buttons for future screens here
  }

  void display() {
    fill(0);
    textSize(32);
    textAlign(CENTER);
    text("Welcome to Payslip Explainer", width/2, 100);
    
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
    fill(0);
    textSize(28);
    textAlign(CENTER);
    text("Payslip Calculator Screen", width/2, 100);
    
    // Placeholder for input fields
    fill(50);
    rect(250, 200, 300, 50);
    fill(255);
    textAlign(LEFT, CENTER);
    text("Gross Salary Input (placeholder)", 260, 225);
    
    displayWidgets();
  }
}
