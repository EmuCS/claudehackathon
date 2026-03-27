// ================= GLOBALS =================
int screen = 0;

InputField nameField, salaryField, pensionField, healthField, loanField, ageField, rentField, tuitionField;

YesNoToggles personalCreditToggle, payeCreditToggle, homeCarerToggle, singleParentToggle, rentCreditToggle, tuitionCreditToggle;

String period = "Monthly";

// layout helpers
float leftCol, centerX, rowGap;
float payPeriodY;

// ================= SETUP =================
void setup() {
  fullScreen();

  nameField = new InputField(0, 0, width * 0.25, 30, "Name");
  salaryField = new InputField(0, 0, width * 0.25, 30, "Salary");
  pensionField = new InputField(0, 0, width * 0.25, 30, "Pension");
  healthField = new InputField(0, 0, width * 0.25, 30, "Health");
  loanField = new InputField(0, 0, width * 0.25, 30, "Loan");
  ageField = new InputField(0, 0, width * 0.25, 30, "Age");

  rentField = new InputField(0, 0, width * 0.2, 30, "Rent");
  tuitionField = new InputField(0, 0, width * 0.2, 30, "Tuition");

  personalCreditToggle = new YesNoToggles(0, 0, "Personal Credit");
  payeCreditToggle     = new YesNoToggles(0, 0, "PAYE Credit");
  homeCarerToggle      = new YesNoToggles(0, 0, "Home Carer");
  singleParentToggle   = new YesNoToggles(0, 0, "Single Parent");
  rentCreditToggle     = new YesNoToggles(0, 0, "Rent Credit");
  tuitionCreditToggle  = new YesNoToggles(0, 0, "Tuition Credit");
}

// ================= DRAW =================
void draw() {
  background(0);
  updateLayout();

  if (screen == 0) drawInputScreen();
  if (screen == 1) drawCreditsScreen();
  if (screen == 2) drawResultsScreen();
  if (showInfoBox) drawInfoBox();
}

// ================= LAYOUT =================
void updateLayout() {
  centerX = width * 0.5;
  leftCol = width * 0.25;
  rowGap = height * 0.075;
}

// ================= SCREEN 1 =================
void drawInputScreen() {
  fill(40, 255, 0);
  textSize(26);
  text("taxÉIRE — Payslip", centerX - 150, height * 0.08);
  textSize(16);

  float y = height * 0.2;

  drawField("Name:", nameField, y); y += rowGap;
  drawField("Gross Salary (€):", salaryField, y); y += rowGap;

  fill(40, 255, 0);
  text("Pay Period:", leftCol - 120, y);

  payPeriodY = y;

  fill(40, 255, 0);
  text(period + " (click)", leftCol, y);

  y += rowGap;
  drawField("Pension:", pensionField, y); y += rowGap;
  drawField("Health Insurance:", healthField, y); y += rowGap;
  drawField("Student Loan:", loanField, y); y += rowGap;
  drawField("Age:", ageField, y);

  drawButton(centerX - 100, height * 0.85, 200, 50, "Next");
}

// ================= SCREEN 2 =================
void drawCreditsScreen() {
  background(0);
  fill(40, 255, 0);
  textSize(24);
  text("Tax Credits", centerX - 100, height * 0.1);
  textSize(16);

  float y = height * 0.2;

  y = drawToggle(personalCreditToggle, y);
  y = drawToggle(payeCreditToggle, y);
  y = drawToggle(homeCarerToggle, y);
  y = drawToggle(singleParentToggle, y);

  // RENT
  rentCreditToggle.x = leftCol;
  rentCreditToggle.y = y;
  rentCreditToggle.display();

  if (rentCreditToggle.isYes()) {
    rentField.x = leftCol + width * 0.45;
    rentField.y = y - height * 0.01;
    rentField.w = width * 0.2;
    rentField.display();
  }
  y += rowGap;

  // TUITION
  tuitionCreditToggle.x = leftCol;
  tuitionCreditToggle.y = y;
  tuitionCreditToggle.display();

  if (tuitionCreditToggle.isYes()) {
    tuitionField.x = leftCol + width * 0.45;
    tuitionField.y = y - height * 0.01;
    tuitionField.w = width * 0.2;
    tuitionField.display();
  }

  drawButton(centerX - 200, height * 0.85, 150, 50, "Back");
  drawButton(centerX + 50, height * 0.85, 200, 50, "Calculate");
}

// ================= SCREEN 3 =================
void drawResultsScreen() {
  background(0);

  float gross = scaleToYear(parseFloatSafe(salaryField.text));
  float pension = scaleToYear(parseFloatSafe(pensionField.text));
  float health = scaleToYear(parseFloatSafe(healthField.text));
  float loan = scaleToYear(parseFloatSafe(loanField.text));
  int age = int(parseFloatSafe(ageField.text));

  float taxable = max(0, gross - pension);

  float incomeTax = calcIncomeTax(taxable);
  float usc = calcUSC(gross, age);
  float prsi = calcPRSI(gross);

  float credits = calcCredits(taxable, age);

  incomeTax = max(0, incomeTax - credits);

  float totalTax = incomeTax + usc + prsi;
  float netYearly = gross - totalTax - health - loan;

  float net = scaleFromYear(netYearly);

  float y = height * 0.15;
  float lh = height * 0.06;

  textSize(22);
  fill(40, 255, 0);
  text("Final Take-Home Pay: €" + nf(net, 0, 2), leftCol, y);
  y += lh * 1.5;

  textSize(18);
  text("Income Tax: €" + nf(scaleFromYear(incomeTax), 0, 2), leftCol, y); y += lh;
  text("USC: €" + nf(scaleFromYear(usc), 0, 2), leftCol, y); y += lh;
  text("PRSI: €" + nf(scaleFromYear(prsi), 0, 2), leftCol, y); y += lh;
  text("Health Insurance: €" + nf(scaleFromYear(health), 0, 2), leftCol, y); y += lh;
  text("Student Loan: €" + nf(scaleFromYear(loan), 0, 2), leftCol, y); y += lh;

  drawChart(
    scaleFromYear(incomeTax),
    scaleFromYear(usc),
    scaleFromYear(prsi),
    net
  );

  drawButton(centerX - 100, height * 0.85, 200, 50, "Restart");
}

// ================= HELPERS =================
void drawField(String label, InputField field, float y) {
  fill(40, 255, 0);
  text(label, leftCol - 120, y);
  field.x = leftCol;
  field.y = y - 15;
  field.display();
}

float drawToggle(YesNoToggles toggle, float y) {
  toggle.x = leftCol;
  toggle.y = y;
  toggle.display();
  return y + rowGap;
}

void drawButton(float x, float y, float w, float h, String label) {
  fill(0, 120, 255);
  rect(x, y, w, h, 10);
  fill(40, 255, 0);
  textAlign(CENTER, CENTER);
  text(label, x + w/2, y + h/2);
  textAlign(LEFT, BASELINE);
}

float parseFloatSafe(String s) {
  try {
    return Float.parseFloat(s);
  } 
  catch (Exception e) {
    println("Invalid number: " + s);
    return 0;
  }
}

// ================= INPUT =================
void mousePressed() {

  if (showInfoBox) {
    float w = width * 0.5;
    float h = height * 0.4;
    float x = width * 0.25;
    float y = height * 0.3;

    if (overButton(x + w - 80, y + 10, 60, 30)) {
      showInfoBox = false;
    }
    return;
  }

  if (screen == 0) {

    nameField.mousePressed();
    salaryField.mousePressed();
    pensionField.mousePressed();
    healthField.mousePressed();
    loanField.mousePressed();
    ageField.mousePressed();

    if (overButton(centerX - 100, height * 0.85, 200, 50)) {
      showInfoBox = false;
      screen = 1;
    }

    float y = height * 0.2 + rowGap * 2;
    if (mouseX > leftCol && mouseX < leftCol + 150 &&
        mouseY > y - 20 && mouseY < y + 10) {

      if (period.equals("Monthly")) period = "Weekly";
      else if (period.equals("Weekly")) period = "Yearly";
      else period = "Monthly";
    }
  }

  else if (screen == 1) {

    personalCreditToggle.handleClick(mouseX, mouseY);
    payeCreditToggle.handleClick(mouseX, mouseY);
    homeCarerToggle.handleClick(mouseX, mouseY);
    singleParentToggle.handleClick(mouseX, mouseY);
    rentCreditToggle.handleClick(mouseX, mouseY);
    tuitionCreditToggle.handleClick(mouseX, mouseY);

    rentField.mousePressed();
    tuitionField.mousePressed();

    if (overButton(centerX - 200, height * 0.85, 150, 50)) {
      showInfoBox = false;
      screen = 0;
    }

    if (overButton(centerX + 50, height * 0.85, 200, 50)) {
      showInfoBox = false;
      screen = 2;
    }
  }

  else if (screen == 2) {

    if (overButton(centerX - 100, height * 0.85, 200, 50)) {
      showInfoBox = false;
      screen = 0;
    }
  }
}

boolean overButton(float x, float y, float w, float h) {
  return mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h;
}

void keyTyped() {
  nameField.keyTyped(key);
  salaryField.keyTyped(key);
  pensionField.keyTyped(key);
  healthField.keyTyped(key);
  loanField.keyTyped(key);
  ageField.keyTyped(key);
  rentField.keyTyped(key);
  tuitionField.keyTyped(key);
}// ================= INFO BOX PLACEHOLDERS =================
boolean showInfoBox = false;
String infoBoxTitle = "";
String infoBoxText = "";

String getExplanation(String label) {
  if (label.equals("Personal Credit"))
    return "A tax credit that reduces the amount of tax you pay each year.";

  if (label.equals("PAYE Credit"))
    return "Given to employees paying tax through PAYE. Helps reduce tax owed.";

  if (label.equals("Home Carer"))
    return "For families where one person stays home to care for dependents.";

  if (label.equals("Single Parent"))
    return "Supports single parents with additional tax relief.";

  if (label.equals("Rent Credit"))
    return "Tax relief available for renters in Ireland.";

  if (label.equals("Tuition Credit"))
    return "Tax relief on certain education fees.";

  return "Information not available.";
}

void drawInfoBox() {
  float w = width * 0.5;
  float h = height * 0.4;
  float x = width * 0.25;
  float y = height * 0.3;

  // Dim background
  fill(0, 150);
  rect(0, 0, width, height);

  // Info box background
  fill(0); 
  rect(x, y, w, h, 15);

  // Title text
  fill(40, 255, 0);
  textSize(20);
  text(infoBoxTitle, x + 20, y + 40);

  // Body text
  textSize(14);
  text(infoBoxText, x + 20, y + 80, w - 40, h - 120);

  // Close button
  fill(200, 60, 60);
  rect(x + w - 80, y + 10, 60, 30, 8);

  fill(40, 255, 0);
  textAlign(CENTER, CENTER);
  text("Close", x + w - 50, y + 25);
  textAlign(LEFT, BASELINE);
}

////// IRISH TAX CALCULATOR (OLD SIMPLE VERSION — UNUSED NOW) /////////
float[] calculateTax(float income) {
  float incomeTax = 0;
  float usc = 0;
  float prsi = 0;

  if (income <= 40000) {
    incomeTax = income * 0.20;
  } else {
    incomeTax = 40000 * 0.20 + (income - 40000) * 0.40;
  }

  if (income <= 12012) usc = income * 0.005;
  else if (income <= 25760) usc = 12012 * 0.005 + (income - 12012) * 0.02;
  else usc = 12012 * 0.005 + (25760 - 12012) * 0.02 + (income - 25760) * 0.045;

  prsi = income * 0.04;

  return new float[]{incomeTax, usc, prsi};
}

///////// HELPER /////////////////////////////////////////////////////
void drawStep(String label, float value, float y) {
  fill(40, 255, 0);
  text(label, leftCol, y);
  text("€" + nf(value, 0, 2), leftCol + 250, y);
}

// =========================
// PERIOD SCALING
// =========================
float scaleToYear(float amount) {
  if (period.equals("Weekly")) return amount * 52f;
  if (period.equals("Monthly")) return amount * 12f;
  return amount;
}

float scaleFromYear(float amount) {
  if (period.equals("Weekly")) return amount / 52f;
  if (period.equals("Monthly")) return amount / 12f;
  return amount;
}

// =========================
// REAL IRISH TAX BANDS (2024)
// =========================
float calcIncomeTax(float taxableYearly) {
  float band = 42000;
  float tax = 0;

  if (taxableYearly <= band) {
    tax = taxableYearly * 0.20;
  } else {
    tax = band * 0.20 + (taxableYearly - band) * 0.40;
  }

  return tax;
}

// =========================
// REAL USC (2024)
// =========================
float calcUSC(float incomeYearly, int age) {
  if (age < 70 && incomeYearly < 13000) return 0;

  float usc = 0;
  float remaining = incomeYearly;

  float band1 = 12012;
  float band2 = 10908;
  float band3 = 47124;

  if (remaining > 0) {
    float a = min(remaining, band1);
    usc += a * 0.005;
    remaining -= a;
  }
  if (remaining > 0) {
    float a = min(remaining, band2);
    usc += a * 0.02;
    remaining -= a;
  }
  if (remaining > 0) {
    float a = min(remaining, band3);
    usc += a * 0.04;
    remaining -= a;
  }
  if (remaining > 0) {
    usc += remaining * 0.08;
  }

  return usc;
}

// =========================
// REAL PRSI (Class A)
// =========================
float calcPRSI(float incomeYearly) {
  float weekly = incomeYearly / 52f;
  if (weekly < 352) return 0;
  return incomeYearly * 0.04;
}

// =========================
// REAL CREDITS
// =========================
float calcCredits(float incomeYearly, int age) {
  float credits = 0;

  credits += 1875;
  credits += 1875;

  if (homeCarerToggle.isYes()) {
    float income = incomeYearly;
    if (income <= 10400) credits += 1800;
    else if (income <= 12800) {
      float reduction = (income - 10400) / 2f;
      credits += max(0, 1800 - reduction);
    }
  }

  if (singleParentToggle.isYes()) credits += 1750;

  if (rentCreditToggle.isYes() && age >= 23) {
    credits += 750;
  }

  if (tuitionCreditToggle.isYes()) {
    float fees = scaleToYear(parseFloatSafe(tuitionField.text));
    float allowable = max(0, fees - 3000);
    credits += min(allowable * 0.20, 1500);
  }

  return credits;
}

///////// BAR CHART VISUAL ////////////////////////////////////////////
void drawChart(float tax, float usc, float prsi, float net) {
  float total = tax + usc + prsi + net;

  float x = width * 0.65;
  float y = height * 0.3;
  float h = height * 0.4;
  float w = 40;

  float taxH = (tax / total) * h;
  float uscH = (usc / total) * h;
  float prsiH = (prsi / total) * h;
  float netH = (net / total) * h;

  fill(200, 80, 80);
  rect(x, y + h - taxH, w, taxH);

  fill(255, 180, 80);
  rect(x + 60, y + h - uscH, w, uscH);

  fill(80, 120, 255);
  rect(x + 120, y + h - prsiH, w, prsiH);

  fill(80, 200, 120);
  rect(x + 180, y + h - netH, w, netH);

  fill(40, 255, 0);
  text("Tax", x, y + h + 20);
  text("USC", x + 60, y + h + 20);
  text("PRSI", x + 120, y + h + 20);
  text("Net", x + 180, y + h + 20);
}
