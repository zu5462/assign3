int[][] slot;
boolean[][] flagSlot; // use for flag
int bombCount; // 共有幾顆炸彈
int clickCount; // 共點了幾格v
int flagCount; // 共插了幾支旗f
int nSlot; // 分割 nSlot*nSlot格
int totalSlots; // 總格數
final int SLOT_SIZE = 100; //每格大小

int sideLength; // SLOT_SIZE * nSlot
int ix; // (width - sideLength)/2
int iy; // (height - sideLength)/2

// game state
final int GAME_START = 1;
final int GAME_RUN = 2;
final int GAME_WIN = 3;
final int GAME_LOSE = 4;
int gameState;

//click check
int safeclick=0;
int clickcol;
int clickrow;
int checkslot[][];
//slot bomb
int bombrow;
int bombcol;

// slot state for each slot
final int SLOT_OFF = 0;
final int SLOT_SAFE = 1;
final int SLOT_BOMB = 2;
final int SLOT_FLAG = 3;
final int SLOT_FLAG_BOMB = 4;
final int SLOT_DEAD = 5;
final int SLOT_CHECK=6;

PImage bomb, flag, cross ,bg;

void setup(){
  size (640,480);
  textFont(createFont("font/Square_One.ttf", 20));
  bomb=loadImage("data/bomb.png");
  flag=loadImage("data/flag.png");
  cross=loadImage("data/cross.png");
  bg=loadImage("data/bg.png");

  nSlot = 4;
  totalSlots = nSlot*nSlot;
  // 初始化二維陣列
  slot = new int[nSlot][nSlot];
  checkslot= new int[nSlot][nSlot];
  sideLength = SLOT_SIZE * nSlot;
  ix = (width - sideLength)/2; // initial x
  iy = (height - sideLength)/2; // initial y
  
  gameState = GAME_START;
}

void draw(){
//game show
if(gameState==GAME_WIN ||gameState==GAME_LOSE){
       for (int showcol=0; showcol < nSlot; showcol++){
         for (int showrow=0; showrow < nSlot; showrow++){
              if(checkslot[showcol][showrow]==SLOT_FLAG_BOMB){
                showSlot(showcol, showrow, slot[showcol][showrow]);
                slot[showcol][showrow]=SLOT_FLAG_BOMB;
              }
               showSlot(showcol, showrow, slot[showcol][showrow]);
           }
         }
      }
      
  switch (gameState){
    case GAME_START:
          background(180);
          image(bg,0,0,640,480);
          textFont(loadFont("font/Square_One.ttf"),15)
          fill(0);
          text("Choose # of bombs to continue:",10,width/3-24);
          int spacing = width/9;
          for (int i=0; i<9; i++){
            fill(255);
            rect(i*spacing, width/3, spacing, 50);
            fill(0);
            text(i+1, i*spacing, width/3+24);
          }
          // check mouseClicked() to start the game
          break;
    case GAME_RUN:
          //---------------- put you code here ----                 
            if(safeclick==(totalSlots-bombCount)){
            gameState=GAME_WIN;
            }
          // -----------------------------------
          break;
    case GAME_WIN:  
          textFont(loadFont("font/Square_One.ttf"),16)
          fill(0);
          text("YOU WIN !!",width/3,30);
          break;
    case GAME_LOSE:
          textFont(loadFont("font/Square_One.ttf"),16)
          fill(0);
          text("YOU LOSE !!",width/3,30);
          break;
  }
}

   
int countNeighborBombs(int col,int row){
  // -------------- Requirement B ---------
  int count=0;
  for (int countcol=col-1; countcol < col+2; countcol++){
    for (int countrow=row-1; countrow < row+2; countrow++){
      if(countcol<0 || countcol>3 || countrow<0 || countrow>3){
        continue;
      }
      else if(slot[countcol][countrow] == SLOT_BOMB || slot[countcol][countrow] == SLOT_DEAD || slot[countcol][countrow]==SLOT_FLAG_BOMB){
           count++;
     }
    }
  }
  return count;
}


void setBombs(){
  // initial slot
  for (int col=0; col < nSlot; col++){
    for (int row=0; row < nSlot; row++){
      slot[col][row] = SLOT_OFF;
    }
  }
  // -------------- put your code here ---------
  // randomly set bombs
  for (int col=0; col < nSlot; col++){
    for (int row=0; row < nSlot; row++){
      slot[col][row] = SLOT_SAFE;
    }
  }
  
   for(int put=0; put<bombCount;put++){
       bombcol=int(random(4));
       bombrow=int(random(4));
       if(slot[bombcol][bombrow]==SLOT_BOMB){
         put-=1;
       }
       else{
       slot[bombcol][bombrow]=SLOT_BOMB;
 
       }
   }
    

  // ---------------------------------------
}

void drawEmptySlots(){
  background(180);
  image(bg,0,0,640,480);
  for (int col=0; col < nSlot; col++){
    for (int row=0; row < nSlot; row++){
        showSlot(col, row, SLOT_OFF);
    }
  }
}

void showSlot(int col, int row, int slotState){
  int x = ix + col*SLOT_SIZE;
  int y = iy + row*SLOT_SIZE;
  switch (slotState){
    case SLOT_OFF:
         fill(222,119,15);
         stroke(0);
         rect(x, y, SLOT_SIZE, SLOT_SIZE);
         break;
    case SLOT_BOMB:
          fill(255);
          rect(x,y,SLOT_SIZE,SLOT_SIZE);
          image(bomb,x,y,SLOT_SIZE, SLOT_SIZE);
          break;
    case SLOT_SAFE:
          fill(255);
          rect(x,y,SLOT_SIZE,SLOT_SIZE);
          int count = countNeighborBombs(col,row);
          if (count != 0){
            fill(0);
            textFont(loadFont("font/Square_One.ttf"),(SLOT_SIZE*3/5));
            text( count, x+15, y+15+SLOT_SIZE*3/5);
          }
          break;
    case SLOT_FLAG:
          image(flag,x,y,SLOT_SIZE,SLOT_SIZE);
          break;
    case SLOT_FLAG_BOMB:
          image(cross,x,y,SLOT_SIZE,SLOT_SIZE);
          break;
    case SLOT_DEAD:
          fill(255,0,0);
          rect(x,y,SLOT_SIZE,SLOT_SIZE);
          image(bomb,x,y,SLOT_SIZE,SLOT_SIZE);
          break;
    case SLOT_CHECK:
         break;
  }
}

// select num of bombs
void mouseClicked(){
  if ( gameState == GAME_START &&
       mouseY > width/3 && mouseY < width/3+50){
       // select 1~9
       //int num = int(mouseX / (float)width*9) + 1;
       int num = (int)map(mouseX, 0, width, 0, 9) + 1;
       // println (num);
       bombCount = num;
       
       // start the game
       clickCount = 0;
       flagCount = 0;
       setBombs();
       drawEmptySlots();
       gameState = GAME_RUN;
  }
}

void mousePressed(){
  if ( gameState == GAME_RUN &&
       mouseX >= ix && mouseX <= ix+sideLength && 
       mouseY >= iy && mouseY <= iy+sideLength){
    
    // --------------- put you code here -------
    clickcol= int((mouseX-ix)/SLOT_SIZE);
    clickrow= int((mouseY-iy)/SLOT_SIZE);
    if(mouseButton==LEFT && checkslot[clickcol][clickrow]!=SLOT_FLAG){    
    showSlot(clickcol, clickrow, slot[clickcol][clickrow]);
   // println(safeclick);
     if (slot[clickcol][clickrow]==SLOT_BOMB){
             slot[clickcol][clickrow]=SLOT_DEAD;
             gameState=GAME_LOSE;
             }
            
    if (slot[clickcol][clickrow]==SLOT_SAFE && checkslot[clickcol][clickrow]!=SLOT_SAFE){
        checkslot[clickcol][clickrow]=SLOT_SAFE;
              safeclick++;
            }
    }
    if(mouseButton==RIGHT){
        if(checkslot[clickcol][clickrow]==SLOT_FLAG ||checkslot[clickcol][clickrow]==SLOT_FLAG_BOMB){
          showSlot(clickcol, clickrow, SLOT_OFF);
          checkslot[clickcol][clickrow]=SLOT_OFF;    
          flagCount-=1;
          }
        else if(flagCount < bombCount && checkslot[clickcol][clickrow]!=SLOT_SAFE){
          showSlot(clickcol, clickrow, SLOT_FLAG);
          checkslot[clickcol][clickrow]=SLOT_FLAG;
          flagCount+=1;
           if(slot[clickcol][clickrow]==SLOT_BOMB){
             checkslot[clickcol][clickrow]=SLOT_FLAG_BOMB;
        }
      }
    }
   }
    // -------------------------
    
  }


// press enter to start
void keyPressed(){
  if(key==ENTER && (gameState == GAME_WIN || 
                    gameState == GAME_LOSE)){
     gameState = GAME_START;
     safeclick=0;
   for (int col=0; col < nSlot; col++){
    for (int row=0; row < nSlot; row++){
      checkslot[col][row] = SLOT_OFF;
    }
  }
}
}
