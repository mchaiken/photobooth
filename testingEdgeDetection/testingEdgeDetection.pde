import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;
AudioPlayer shutter;
boolean curtains=false;
boolean space = false;
boolean edge =false;
boolean invert = false;
boolean bw = false;
boolean tint = false;
boolean colorEdges = false;
/**
 * Getting Started with Capture.
 * 
 * Reading and displaying an image from an attached Capture device. 
 */
double time= millis();
import processing.video.*;
int imgCount = 0;
Capture cam;
int thresh=10;
void setup() {
  size(640, 480);

  String[] cameras = Capture.list();
  minim = new Minim(this); 

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } 
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }  
    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[0]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

    // Start capturing the images from the camera
    cam.start();
  }
}
void draw() {
  color[]temp=new color[480*640];
  color[]temp2=new color[480*640];
  if (tint) {
    int[] rgb= {
      thresh * 10, (thresh * 10) -150, (thresh * 10)-255
    };
    for (int i=0; i< rgb.length; i++) {
      if (rgb[i] >255 || rgb[i]<0) {
        rgb[i]=50;
      }
    }
    tint(rgb[0], rgb[1], rgb[2]);
  } else
    tint(255);
  if (cam.available() == true) {
    cam.read();
  }

  image(cam, 0, 0);
  if (edge || bw) {

    loadPixels();
    float up ;
    float down;
    float left;
    float right ;
    int val;
    for (int y = 1; y < 478; y++) {
      for (int x= 1; x < 638; x++) {
        color w= pixels[y*640+x];
        w=color((int)(red(w)+green(w)+blue(w)) / 3);
        if (bw) {
          w=color(red(w)-((100-(red(w))*thresh)));
        }
        temp2[y*640+x]=w;
      }
    }

    if (edge) {
      for (int y = 1; y < 478; y++) {
        for (int x= 1; x < 638; x++) {
          up = red(temp2[(y*640)+(x-1)]);
          down = red(temp2[y*640+(x+1)]);
          left = red(temp2[((y-1)*640)+x]);
          right = red(temp2[((y+1)*640)+x]); 
          val=(int)sqrt(sq(left-right)+sq(up-down));
          if (val>thresh) {
            val=255;
          }
          if (invert) {
            val= 255-val;
          }

          temp[y*640+x]=color(val);
        }
      }
    }
    if (bw) {
      temp=temp2;
    }
    for (int y = 1; y < 478; y++) {
      for (int x= 1; x < 638; x++) {
        if (!colorEdges) {
          pixels[y*640+x]=temp[y*640+x];
        } else {
          if (red(temp[y*640+x]) != 255) {
            pixels[y*640+x]=temp[y*640+x];
          }
        }
      }
    }
    updatePixels();
  }


  if (curtains) {
    image(loadImage("curtains.png"), 0, 0);
  }
  if (space) {
    image(loadImage("space.png"), 0, 0);
  }


  // The following does the same as the above image() line, but 
  // is faster when just drawing the image without any additional 
  // resizing, transformations, or tint.
  //set(0, 0, cam);
}

void keyPressed() {
  println(keyCode);
  if (keyCode == 32) {
    imgCount++;
    shutter = minim.loadFile("shutter.mp3");
    shutter.play();
    saveFrame("line-"+imgCount+".jpg");
    String currentImg = "line-"+imgCount+".jpg";
    time= millis();
    while (millis () < time+1000) {
      image(loadImage(currentImg), 0, 0);
    }
  } else if (keyCode == 38 ) {
    thresh--;
  } else if (keyCode == 40 ) {
    thresh ++;
  } else if (keyCode == 69) {
    thresh=10;
    edge=!edge;
    space=false;
    curtains=false;
    bw=false;
  } else if (keyCode == 73) {
    invert=!invert;
  } else if (keyCode == 67) {
    curtains=!curtains;
    space=false;
  } else if (keyCode == 83) {
    space=!space;
    curtains=false;
  } else if (keyCode == 66) {
    edge=false;
    tint=false;
    colorEdges = false;
    thresh=1;
    bw=!bw;
  } else if (keyCode == 79) {
    colorEdges = !colorEdges;
  } else if (keyCode == 84) {
    thresh=10;
    tint = !tint ;
    bw=false;
  }
  keyCode = 0;
}

