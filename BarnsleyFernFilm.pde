import java.util.Arrays;

int stateNb = 4;

//starting parameters (between two parameters set)
float[] asi = {0,0.85,0.20,-0.15};
float[] bsi = {0,0.04,-0.26,0.28};
float[] csi = {0,-0.04,0.23,0.26};
float[] dsi = {0.16,0.85,0.22,0.24};
float[] esi = {0,0,0,0};
float[] fsi = {0,1.60,1.60,0.44};

//current parameters
float[] as = {0,0.85,0.20,-0.15};
float[] bs = {0,0.04,-0.26,0.28};
float[] cs = {0,-0.04,0.23,0.26};
float[] ds = {0.16,0.85,0.22,0.24};
float[] es = {0,0,0,0};
float[] fs = {0,1.60,1.60,0.44};
float[] proba = {0.01,0.85,0.07,0.07};

//final parameters
float[] ast = {0,0.85,0.20,-0.15};
float[] bst = {0,0.04,-0.26,0.28};
float[] cst = {0,-0.04,0.23,0.26};
float[] dst = {0.16,0.85,0.22,0.24};
float[] est = {0,0,0,0};
float[] fst = {0,1.60,1.60,0.44};

float x = 0;
float y = 0;
PVector col = new PVector(0,0,0);

//set this to false to explore the parameter space
//set this to true to record film
boolean filming = false;

//t is between 0 et 1, 0 means the image corresponding to the starting parameters are displayed, 1 means the image corresponding to the final parameters are displayed
float t = 0;

int sideSpace = 10;

int nitt = 1000000;
float dt = 0.0002;
int appSpeed = 16;
int fadeSpeed = 16;

String fileName = "coeffs.txt";
int actLine = 0;

void setup(){
  size(1800,1200);
  background(0);
  noStroke();
  loadCoeff(0);
  
  loadCoeffi(actLine);
  actLine = (actLine+1)%loadStrings("coeffs.txt").length;
  loadCoefft(actLine);
  
  showFig();
}

int nextPt(){
  float randNb = random(1);
  int state = -1;
  for(float i = 0;i<randNb;i+=proba[state]){
    state++;
  }
  if(state == -1){
    state = 0;
  }
  
  float nx = x;
  float ny = y;
  try{
    nx = as[state]*x + bs[state]*y + es[state];
    ny = cs[state]*x + ds[state]*y + fs[state];
  }catch(Exception e){
    println(x,y,"error");
  }
  
  x = nx;
  y = ny;
  
  
  return state;
}

void draw(){
  
  if(filming){
    setState();
    showFig();
    t += dt;
    if(t>1){ //load the next parameters in line
      loadCoeffi(actLine);
      actLine = (actLine+1)%loadStrings("coeffs.txt").length;
      loadCoefft(actLine);
      t = 0;
    }
  }
  if(frameCount%15==0){ //periodically saves the displayed image
    saveFrame("output/img######.png");
  }
}

void setState(){
  float u = 3*t*t - 2*t*t*t; //A smooth interpolation between 0 and 1
  
  for(int i = 0;i<stateNb;i++){
    as[i] = asi[i] * (1-u) + ast[i] * u;
    bs[i] = bsi[i] * (1-u) + bst[i] * u;
    cs[i] = csi[i] * (1-u) + cst[i] * u;
    ds[i] = dsi[i] * (1-u) + dst[i] * u;
    es[i] = esi[i] * (1-u) + est[i] * u;
    fs[i] = fsi[i] * (1-u) + fst[i] * u;
  }
}

void showFig(){
  if(!filming){
    background(0);
  }
  loadPixels();
  
  int[] mod = new int[pixels.length];
  
  for(int i = 0;i<nitt;i++){
    nextPt();
    
    
    float drawy = map(x,-5,5,height,0);
    float drawx = map(y,-3,15,0,width);
    
    
    int loc = floor(drawx) + floor(drawy)*width;
    if(drawx<width && drawy<height && drawx>0 && drawy > 0){
      mod[loc] = 1;
    }
    
    //I use this to draw the large still images. But it is way to slow to be used in the film or in the search process
    /*
    float r = 1.5;
    fill(col.x,col.y,col.z,10);
    ellipse(drawx,drawy,r,r);
    */
  }
  for(int i = 0;i<pixels.length;i++){
    if(filming){
      if(mod[i] == 1){
        pixels[i] = color(brightness(pixels[i])+appSpeed);
      }else if(brightness(pixels[i])>0){
        pixels[i] = color(brightness(pixels[i])-fadeSpeed);
      }
    }else{
      pixels[i] = color(255*mod[i]);
    }
  }
  updatePixels();
}

void keyPressed(){
  x = 0;
  y = 0;
  float minRand = -0.25;
  float pluRand = 0.25;
  int startRand = 0;
  float divRand = 0.9;
  float mulRand = 1.1;
  if(key=='a'){
    for(int i = startRand;i<stateNb;i++){
      as[i] += random(minRand,pluRand);
    }
  }
  if(key=='b'){
    for(int i = startRand;i<stateNb;i++){
      bs[i] += random(minRand,pluRand);
    }
  }
  if(key=='c'){
    for(int i = startRand;i<stateNb;i++){
      cs[i] += random(minRand,pluRand);
    }
  }
  if(key=='d'){
    for(int i = startRand;i<stateNb;i++){
      ds[i] += random(minRand,pluRand);
    }
  }
  if(key=='e'){
    for(int i = startRand;i<stateNb;i++){
      es[i] += random(minRand,pluRand);
    }
  }
  if(key=='f'){
    for(int i = startRand;i<stateNb;i++){
      fs[i] += random(minRand,pluRand);
    }
  }
  if(key=='r'){
    for(int i = 0;i<stateNb;i++){
      as[i] = asi[i];
      bs[i] = bsi[i];
      cs[i] = csi[i];
      ds[i] = dsi[i];
      es[i] = esi[i];
      fs[i] = fsi[i];
    }
  }
  if(key=='n'){
    for(int i = 0;i<stateNb;i++){
      as[i] = asi[i];
      bs[i] = bsi[i];
      cs[i] = csi[i];
      ds[i] = dsi[i];
      es[i] = esi[i];
      fs[i] = fsi[i];
    }
    for(int i = startRand;i<stateNb;i++){
      as[i] += random(minRand,pluRand);
      bs[i] += random(minRand,pluRand);
      cs[i] += random(minRand,pluRand);
      ds[i] += random(minRand,pluRand);
    }
  }
  if(key=='m'){
    for(int i = 0;i<stateNb;i++){
      as[i] = asi[i];
      bs[i] = bsi[i];
      cs[i] = csi[i];
      ds[i] = dsi[i];
      es[i] = esi[i];
      fs[i] = fsi[i];
    }
    for(int i = startRand;i<stateNb;i++){
      as[i] *= random(divRand,mulRand);
      bs[i] *= random(divRand,mulRand);
      cs[i] *= random(divRand,mulRand);
      ds[i] *= random(divRand,mulRand);
    }
  }
  if(key=='l'){
    for(int i = startRand;i<stateNb;i++){
      as[i] *= random(divRand,mulRand);
      bs[i] *= random(divRand,mulRand);
      cs[i] *= random(divRand,mulRand);
      ds[i] *= random(divRand,mulRand);
    }
  }
  if(key=='s'){
    actLine = addActCoeff();
  }
  if(keyCode==LEFT){
    actLine = max(0,actLine-1);
    loadCoeff(actLine);
  }
  if(keyCode==RIGHT){
    actLine = min(loadStrings("coeffs.txt").length-1,actLine+1);
    loadCoeff(actLine);
  }
  
  println("coeffs :");
  for(int i = 0;i<stateNb;i++){
    print(as[i]+",");
    print(bs[i]+",");
    print(cs[i]+",");
    print(ds[i]+",");
    print(es[i]+",");
    print(fs[i]+";");
  }
  println("");
  
  showFig();
}

int addActCoeff(){
  String[] coeffs = loadStrings("coeffs.txt");
  String[] nCoeffs = new String[coeffs.length+1];
  for(int i = 0;i<coeffs.length;i++){
    nCoeffs[i] = coeffs[i];
  }
  nCoeffs[coeffs.length] = actCoeffToString();
  saveStrings(fileName,nCoeffs);
  return nCoeffs.length-1;
}

void loadCoeff(int line){
  String[] coeffs = loadStrings("coeffs.txt");
  stringToCoeff(coeffs[line]);
}

void loadCoeffi(int line){
  String[] coeffs = loadStrings("coeffs.txt");
  stringToCoeffi(coeffs[line]);
}

void loadCoefft(int line){
  String[] coeffs = loadStrings("coeffs.txt");
  stringToCoefft(coeffs[line]);
}

String actCoeffToString(){
  String r = "";
  for(int i = 0;i<stateNb;i++){
    if(i!=0)r+=";";
    r+=as[i]+",";
    r+=bs[i]+",";
    r+=cs[i]+",";
    r+=ds[i]+",";
    r+=es[i]+",";
    r+=fs[i];
  }
  return r;
}

void stringToCoeff(String s){
  String[] is = s.split(";");
  for(int i = 0;i<stateNb;i++){
    String[] coeffi = is[i].split(",");
    as[i] = float(coeffi[0]);
    bs[i] = float(coeffi[1]);
    cs[i] = float(coeffi[2]);
    ds[i] = float(coeffi[3]);
    es[i] = float(coeffi[4]);
    fs[i] = float(coeffi[5]);
  }
}

void stringToCoeffi(String s){
  String[] is = s.split(";");
  for(int i = 0;i<stateNb;i++){
    String[] coeffi = is[i].split(",");
    asi[i] = float(coeffi[0]);
    bsi[i] = float(coeffi[1]);
    csi[i] = float(coeffi[2]);
    dsi[i] = float(coeffi[3]);
    esi[i] = float(coeffi[4]);
    fsi[i] = float(coeffi[5]);
  }
}

void stringToCoefft(String s){
  String[] is = s.split(";");
  for(int i = 0;i<stateNb;i++){
    String[] coeffi = is[i].split(",");
    ast[i] = float(coeffi[0]);
    bst[i] = float(coeffi[1]);
    cst[i] = float(coeffi[2]);
    dst[i] = float(coeffi[3]);
    est[i] = float(coeffi[4]);
    fst[i] = float(coeffi[5]);
  }
}