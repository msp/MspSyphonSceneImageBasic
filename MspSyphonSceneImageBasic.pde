// based on chSK_scene_image_basic in Making Things See 
// but hacked to include a Syphon server to publish to VDMX

import processing.opengl.*;
import SimpleOpenNI.*;
import codeanticode.syphon.*;

SyphonServer server;
SimpleOpenNI  kinect;
PGraphics VDMXCanvas;

PImage  userImage;
int userID;
int[] userMap;

PImage rgbImage;
void setup() {
  size(640, 480, P3D);
  VDMXCanvas = createGraphics(this.g.width, this.g.height, P3D);

  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser();
  
  // Create syhpon server to send frames out.
  server = new SyphonServer(this, "Processing Syphon");
}

void draw() {
  background(0);
  kinect.update();
  
  // detect any users
  int[] userList = kinect.getUsers();  
  //println("users: "+userList.length);
  
  for(int i=0;i<userList.length;i++) {
    loadPixels();
    
    userMap = kinect.userMap();    
    // println("userMap: "+userMap.length);
    
    for (int j = 0; j < userMap.length; j++) {
      // if the current pixel is on a user
      if (userMap[j] != 0) {
        // make it green        
        pixels[j] = color(0, 255, 0);        
      }
      
      // display the changed pixel array
      updatePixels();        
    }    
  }
   
  copyBuiltInCanvasToVDMX();
  //image(this.g, 0, 0);
}
void copyBuiltInCanvasToVDMX() {
  VDMXCanvas.loadPixels(); 
  arrayCopy(this.g.pixels, VDMXCanvas.pixels); 
  VDMXCanvas.updatePixels();
 
  server.sendImage(VDMXCanvas); 
}

void onNewUser(int uID) {
  userID = uID;
  println("tracking");
}

