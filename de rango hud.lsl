string owner_key;
integer openMenu;
integer subMenu;

integer opt;
integer camo;

integer drawToggle;

float aShow = 1.0;
float aHide = 0.0;
vector cv_1_VECTOR = <1.0,1.0,0.0>;
vector zerovec = ZERO_VECTOR;
string openBg = "abd27309-c1af-d013-0e97-cb01a702eb05";
string closedBg = "3ddede60-661f-a5a7-8f3a-3bb148731204";
string optTEX = "6534c029-3076-5b8e-b3b6-2b0a3101317b";
string camoTEX = "deca1724-abfa-2b23-36e4-2feb8dbb9cbd";
string plusTEX = "0a357f27-b6a1-7655-cd1d-64f651d1b495";
string minusTEX = "1bcc3f1c-0bab-378c-3d5a-0f7a5a9b1e79";
list plus = [PRIM_TEXTURE, 2, plusTEX, cv_1_VECTOR, zerovec, aHide];
list minus = [PRIM_TEXTURE, 2, minusTEX, cv_1_VECTOR, zerovec, aHide];
list open = [PRIM_TEXTURE, 1, openBg, cv_1_VECTOR, zerovec, aHide];
list closed = [PRIM_TEXTURE, 1, closedBg, cv_1_VECTOR, zerovec, aHide];
list options = [PRIM_TEXTURE, ALL_SIDES, optTEX, cv_1_VECTOR, zerovec, aHide];
list camos = [PRIM_TEXTURE, ALL_SIDES, camoTEX, cv_1_VECTOR, zerovec, aHide];


//Lista Options
list optionsList = ["SILENCER", "OPTICS", "LASER","MAG", "LIGHTS", "COLORS"];
//Lista Camos
list camosList = ["DEFAULT", "CAMO1", "CAMO2","CAMO3", "CAMO4", "COLORS"];

//Lista menu principal
list showElements = ["4","5"];
//Menu Avanzado
integer large_link = 4;
integer mini_link = 3;
integer extra_link = 5;
integer bg_link = 2;


hide(){
    integer i;
    
    for(i = 0; i <  llGetListLength(showElements); ++i){
     llSetLinkAlpha(llList2Integer(showElements, i), aHide, ALL_SIDES);
    }
    llSetLinkPrimitiveParamsFast(bg_link, closed);
    llSetLinkPrimitiveParamsFast(1, plus);
    llSetLinkAlpha(mini_link, aShow, ALL_SIDES);
    opt = FALSE;
    camo; FALSE;
   
}
show(){
    llSetLinkPrimitiveParamsFast(bg_link, open);
    llSetLinkPrimitiveParamsFast(1, minus);
    llSetLinkAlpha(mini_link, aHide, ALL_SIDES);
    llSetLinkAlpha(large_link, aShow, ALL_SIDES);
    
}

integer functTest(integer prim, integer cara){
    if(llDetectedLinkNumber(0) == prim && llDetectedTouchFace(0) == cara){
        return TRUE;
    }
    else{
        return FALSE;
    }
}

menuInput()
{
    if(openMenu == TRUE)
    {
        if(functTest(4, 5)){
            reload();
        }
        if(functTest(4, 4)){
            draw();
        }
        if(functTest(4, 0) == TRUE){
            camo = FALSE;
            if(opt == FALSE)
            {
                llSetLinkPrimitiveParamsFast(extra_link, options);
                llSetLinkAlpha(extra_link, aShow, ALL_SIDES);
                opt = TRUE;
                return;
            }
            else
            {
                llSetLinkAlpha(extra_link, aHide, ALL_SIDES);
                opt = FALSE;
                return;
            }
        }
        if(functTest(4, 1) == TRUE){
            opt = FALSE;
            if(camo == FALSE)
            {
                camo = TRUE;
                llSetLinkPrimitiveParamsFast(extra_link, camos);
                llSetLinkAlpha(extra_link, aShow, ALL_SIDES);
                return;
            }
            else
            {
                camo = FALSE;
                llSetLinkAlpha(extra_link, aHide, ALL_SIDES);
                return;
            }
        }
    }
    else
    {
        if(functTest(3, 1)){
            reload();
        }
    
        if(functTest(3, 0)){
            draw();
        }
    }  
}

submenuInput(){
    
    if(llDetectedLinkNumber(0) != extra_link || openMenu == FALSE){
        return;
    }
    
    integer i;
    integer btn = llDetectedTouchFace(0);
    if(opt == TRUE){
        for(i = 0; i <  llGetListLength(optionsList); ++i){
            if(btn == i){
                llSay(0, llList2String(optionsList, i));
                return;
            }  
        }  
    }
    if(camo == TRUE){
        for(i = 0; i <  llGetListLength(camosList); ++i){
            if(btn == i){
                llSay(0, llList2String(camosList, i));
                return;
            }  
        }  
    }
}

reload(){
    
    llSay(-69696666,owner_key+"r");
}
draw(){
    
    if(drawToggle == FALSE)
    {
        llSay(-69696666,owner_key+"d");
        drawToggle = TRUE;
        return;
    }
    else if(drawToggle == TRUE)
    {
        llSay(-69696666,owner_key+"s");
        drawToggle = FALSE;
        return;
    }
}

default

{
    state_entry()
    {
        owner_key = llGetOwner();
    }
   
    
    touch_start(integer total_number)
    {
        if(llDetectedKey(0) != llGetOwner()){
            return;
        }
        //llSay(0, (string)llDetectedLinkNumber(0) +", "+ (string)llDetectedTouchFace(0));
        menuInput();
        submenuInput();
        
        if(llDetectedLinkNumber(0) == 1){
            openMenu++;
            if(openMenu == 1){
                show();
            }
            else{
                openMenu = 0;
                hide();
            }
        }
    }
}

