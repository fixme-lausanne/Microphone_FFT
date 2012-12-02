/** mic_fft_visualisation.pde
 *  Author:       Nemen <nemen@fixme.ch>
 *  Date:         30.11.2012
 *  Description:  Display microphone spectrum
 *                from data from serial.
 */
 
import processing.serial.*;

String  xLabel = "Frequency";
String  yLabel = "Values";
String  Heading = "Arduino microphone FFT";
float Vcc = 255.0;
int NumOfVertDivisions=5;
int NumOfVertSubDivisions=10;
int NumOfBars=64;

Serial myPort;
boolean firstContact = false; 
int[] serialInArray = new int[NumOfBars];
int serialCount = 0;

PFont font;
PImage bg;

int temp;
float yRatio = 0.58;
int BarGap, BarWidth, DivisounsWidth;
int[] bars = new int[NumOfBars];

int ScreenWidth = 800, ScreenHeight=600;
int LeftMargin=100;
int RightMArgin=80;
int TextGap=50;
int GraphYposition=80; 
float BarPercent = 0.4;


void setup() {
    myPort = new Serial(this, Serial.list()[0], 57600);
    DivisounsWidth = (ScreenWidth-LeftMargin-RightMArgin)/(NumOfBars); 
    BarWidth = int(BarPercent*float(DivisounsWidth));
    BarGap = DivisounsWidth - BarWidth;

    bg = loadImage("../../Images/fixme_background.jpg");

    size(ScreenWidth,ScreenHeight);
    font = createFont("Arial",12);

    textAlign(CENTER);
    textFont(font);
}

void draw() {
    background(bg);
    
    Axis();
    Labels();
    PrintBars();
}

void Axis() {
    strokeWeight(1);
    stroke(220);
    for(float x=0;x<=NumOfVertSubDivisions;x++){
        int bars=(ScreenHeight-GraphYposition)-int(yRatio*(ScreenHeight)*(x/NumOfVertSubDivisions));
        line(LeftMargin-15,bars,ScreenWidth-RightMArgin-DivisounsWidth+50,bars);
    }
    strokeWeight(1);
    stroke(180);
    for(float x=0;x<=NumOfVertDivisions;x++){
        int bars=(ScreenHeight-GraphYposition)-int(yRatio*(ScreenHeight)*(x/NumOfVertDivisions));
        line(LeftMargin-15,bars,ScreenWidth-RightMArgin-DivisounsWidth+50,bars);
    }
    strokeWeight(2);
    stroke(90);
    line(LeftMargin-15, ScreenHeight-GraphYposition+2, ScreenWidth-RightMArgin-DivisounsWidth+50, ScreenHeight-GraphYposition+2);
    line(LeftMargin-15,ScreenHeight-GraphYposition+2,LeftMargin-15,GraphYposition+80);
    strokeWeight(1);
}

void Labels() {
    textFont(font,18);
    fill(50);
    rotate(radians(-90));
    text(yLabel,-ScreenHeight/2,LeftMargin-45);
    textFont(font,10);
    for(float x=0;x<=NumOfVertDivisions;x++){
        int bars=(ScreenHeight-GraphYposition)-int(yRatio*(ScreenHeight)*(x/NumOfVertDivisions));
        text(round(x),-bars,LeftMargin-20);
    }

    textFont(font,18);
    rotate(radians(90));  
    text(xLabel,LeftMargin+(ScreenWidth-LeftMargin-RightMArgin-50)/2,ScreenHeight-GraphYposition+40);
    textFont(font,24);
    fill(50);
    text(Heading,LeftMargin+(ScreenWidth-LeftMargin-RightMArgin-50)/2,30);
    textFont(font);
}

void PrintBars() {
    int c=0;
    for (int i=0;i<NumOfBars;i++){   
        fill((0xe4+c),(255-bars[i]+c),(0x1a+c));
        stroke(90);
        rect(i*DivisounsWidth+LeftMargin,   ScreenHeight-GraphYposition,   BarWidth,   -bars[i]);
        fill(0x2e,0x2a,0x2a);
    }
}

void serialEvent(Serial myPort) {

    // read a byte from the serial port:
    int inByte = myPort.read();

    if (firstContact == false) {
        if (inByte == 'A') { 
            myPort.clear();          // clear the serial port buffer
            firstContact = true;     // you've had first contact from the microcontroller
            myPort.write('A');       // ask for more
        } 
    } else {
        // Add the latest byte from the serial port to array:
        serialInArray[serialCount] = inByte;
        serialCount++;

        // If we have 6 bytes:
        if (serialCount > NumOfBars -1 ) {
            for (int x=0;x<NumOfBars;x++) {
                bars[x] = int (yRatio*(ScreenHeight)*(serialInArray[x]/256.0));
            }


            // Send a capital A to request new sensor readings:
            myPort.write('A');
            // Reset serialCount:
            serialCount = 0;
        }
    }
}
