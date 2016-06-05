//~ BEGIN COPYRIGHT, LICENSE AND WARRANTY DISCLAIMER
// # [Asbrandt] Melee Weapon Scriptset - v2.5.4 - u20.Nov.2013 - Copyright (c) 2009-2013 Timber Wolfe - Asbrandt.TW@Gmail.com (EMail), Asbrandt Resident (@SecondLife), Asbrandt Aeon (@Avination)
//  > Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction,
//    including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished
//    to do so, subject to the condition that the above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
//   OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//~ BEGIN CODE CONTRIBUTIONS
// # Dimentox Travanti (@SecondLife) - Providing the DCS2 Personal/HUD Channel formula.
//
//~ BEGIN NON-CODE CONTRIBUTIONS
// # None at this time.
//
//~ BEGIN MISC NOTICES
// # While this project is released under the permissive MIT X11 License, attribution is greatly appreciated and helps development because users provide input for improvement:
//  > The simplest means to provide attribution is to include the following line in a prominent location, such as your Marketplace listing and/or documentation files;
//   "Scripted with the OpenSource [Asbrandt] Melee Weapon Scriptset; https://marketplace.secondlife.com/stores/110772"
//  > The full copyright notice is NOT required to be displayed anywhere other than within the Software itself, the above line is sufficient for the optional attribution.
//
//~ BEGIN CODE

// NOTE - A Basic Alpha function is built into this script that changes the entire Linkset to one Value. The MultiAlpha plugin provides more complex functionality.
// NOTE - Color and Glow functions are not built-in to this script. If they are needed, use the included MultiColor and/or MultiGlow plugins.
// HINT - If you need to find your Avatar UUID, rez a new prim, create a new script inside and replace its contents with: default{state_entry(){llOwnerSay((string)llGetOwner());llDie();}}

///BEGIN CONFIG///
//-System-//
string osWeaponCreator = "26b8ddea-ee70-470c-8303-39baacceadd7";                                    // Comms Filter - This should be your Avatar UUID. This needs to match in MainHand, OffHand, Sheath and HUD Scripts.
integer oiWeaponNumber = 1;                                     // Comms Filter - This should be non-zero and different for each Weapon. This needs to match in MainHand, OffHand and Sheath Scripts.
integer oiCommChan = 1;                                         // Channel: User Input. 0 or Negative is forced to 1.
string osWeaponType = "sword";                                  // Weapon Type parameter used in Toggle and Draw/Sheath Commands. If using the GM/ML Variant, please use the same setting.
string osCommCmbt = "combat";                                   // Command: Toggle Between CommunityCombatSystem (CCS) and DynamicCombatSystem (DCS) Combat Systems.
string osCommAnim = "anims";                                    // Command: Selecting Animation/Sound Set. (Options depend on available Anim Config Notecards.)
string osCommAmbS = "ambient";                                  // Command: Toggle Ambient Sound.
string osCommPart = "particle";                                 // Command: Toggle Hit Effects/Particle Effects.
string osCommPrim = "primcache";                                // Command: Prim Cache Refresh.
integer oiAttachPoint = 0;                                      // Require an Attachment Point to be used. (0 = Off, Else = On) http://wiki.secondlife.com/wiki/LlGetAttached
//-BasicAlpha-//
integer oiBasicAlpha = 1;                                       // Enable the BasicAlpha Feature. (0 = Off, Else = On)
float ofBasicAlphaShow = 1.0;                                   // SHOW-Mode Alpha Value.
float ofBasicAlphaHide = 0.0;                                   // HIDE-Mode Alpha Value.
//-Defaults-//
integer oiDefaultCmbt = 0;                                      // Default Setting: Combat System. (0 = CommunityCombatSystem, Else = DynamicCombatSystem)
//-Animations-//
string osDefaultAnimSet = "default";                            // Default Animation Set Name. Note: This name is case-sensitive. (User Input is -not- case-sensitive.)
                                                                //  Animation Config Notecard text is created by the "[ MWS Util ] AnimSet Config" Object/Script for faster load times!!
//-Dynamic Combat System-//
integer oiDefaultDCSB = 1;                                      // Default Setting: Utilize DCS Personal Channel Bridge. (0 = Off, Else = On.)
string osCommDCSB = "dcsbridge";                                // Command: Toggle use of DCS Personal Channel Bridge.
///*END CONFIG*///

string cs_EOF = "\n\n\n";                                       // Non-Integer/Float SL Constants used more than once should be made Global Variables and referenced from there to save Memory.
key ck_NULL_KEY = "00000000-0000-0000-0000-000000000000";
vector cv_ZERO_VECTOR = <0.0,0.0,0.0>;
rotation cr_ZERO_ROTATION = <0.0,0.0,0.0,1.0>;

integer ci_NEG_ONE = -1;                                        // Negative Integer Constants should be in Hex Notation -or- made Global Variables, Negative Integers in Code use a Negation Operation.

integer ci_SYSTEM_CHANNEL = -1192001000;                        // System Communications Channel for A01 Project.

integer ci_ALL_CONTROLS = 0x5000030F;                           // CONTROL_LBUTTON | CONTROL_ML_LBUTTON | CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT
integer ci_CONTROL_LMB = 0x50000000;                            // CONTROL_LBUTTON | CONTROL_ML_LBUTTON
integer ci_CONTROL_ARROW = 0x0000030F;                          // CONTROL_FWD | CONTROL_BACK | CONTROL_LEFT | CONTROL_RIGHT | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT
integer ci_CONTROL_ANYLEFT = 0x00000104;                        // CONTROL_LEFT | CONTROL_ROT_LEFT
integer ci_CONTROL_ANYRIGHT = 0x00000208;                       // CONTROL_RIGHT | CONTROL_ROT_RIGHT

integer ci_PERM_CONTROLANIM = 0x00008014;                       // PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION | PERMISSION_OVERRIDE_ANIMATIONS

list cl_ANIM_STATES =   [   "Standing","Crouching","Sitting","Sitting on Ground","Turning Left","Turning Right","Walking","Striding","Running","CrouchWalking",
                            "PreJumping","Jumping","Falling Down","Soft Landing","Landing","Standing Up","Taking Off","Hovering","Flying","FlyingSlow","Hovering Up","Hovering Down"
                        ];

string cs_NULL_ANIM_CONFIG = "|||0.0|||0.0✕|||||||||||||||||||||✕|||✕1|1|1|0|0";

integer giTempInt;
float gfTempFloat;
string gsTempStr;
key gkTempKey;

key gkOwnerKey;
string gsOwnerName;
string gsWeaponCode;
string gsCommPrefix;
integer giAttached;
integer giSystemListen;
integer giInputListen;

integer giDCSBridge;
integer giDCSChannel;
integer giDCSListen;

integer giPermissions;

integer giCombatMode;
integer giCombatStats;
integer giAmbSound;
integer giParticle;

integer giCombatControl;
integer giControlHold;
vector gvCombatParam;

integer giRunning;
integer giDrawn;

string gsNotecardName;
integer giLoadLine;
key gkLoadRequest;
string gsConfigString;

list glActiveEfcts;
list glStanceAnims;
string gsCurSoun;

list glActiveAttk;
integer giAttkNoDir;
integer giActiveAttk;
integer giActiveAttkDI;
integer giActiveAttkLI;
integer giActiveAttkRI;

float gfNextAttack;
string gsMisSound;
string gsHitSound;
string gsHitEfect;

unInitDefaults()
{
    gsWeaponCode = llMD5String(osWeaponCreator,oiWeaponNumber);
    gsCommPrefix = "A01|"+gsWeaponCode+"|";

    if( oiCommChan < 1 ) { oiCommChan = 1; }

    gsNotecardName = ".anim " + osDefaultAnimSet;

    giAmbSound = 1;
    giParticle = 1;

    giDCSBridge = (oiDefaultDCSB != 0);
    giCombatMode = (oiDefaultCmbt != 0);
}

unInitSystem(integer viCheckAttach)
{
    llListenRemove(giSystemListen);
    llListenRemove(giInputListen);
    llListenRemove(giDCSListen);

    giPermissions = 0;
    giDrawn = 0;
    if( gsCurSoun ) { llStopSound(); gsCurSoun = ""; }

    gkOwnerKey = llGetOwner();
    gsOwnerName = llKey2Name(gkOwnerKey);

    giDCSChannel = (integer)("0x"+llGetSubString((string)gkOwnerKey,0,6))+100;
    giDCSChannel += (10000*(giDCSChannel < 1000));

    if( viCheckAttach ) { unCheckAttach(); }

    unCombatModes();
}

unCheckAttach()
{
    giAttached = llGetAttached();
    if( giAttached )
    {
        if( oiAttachPoint && giAttached != oiAttachPoint )
        {
            llOwnerSay("<< Incorrect Attachment Point. >>");
            llRequestPermissions(gkOwnerKey, 0x00000020);
            return;
        }
        else
        {
            llRequestPermissions(gkOwnerKey, ci_PERM_CONTROLANIM);
            llMessageLinked(ci_NEG_ONE,0x00000002,"0|"+(string)giParticle,"0");
            if( oiBasicAlpha ) { llSetLinkAlpha(ci_NEG_ONE, ofBasicAlphaHide, ci_NEG_ONE); }

            llListenRemove(giInputListen);

            giSystemListen = llListen(ci_SYSTEM_CHANNEL, "", ck_NULL_KEY, "");
            giInputListen = llListen(oiCommChan, "", gkOwnerKey, "");
            if( giDCSBridge ) { giDCSListen = llListen(giDCSChannel, "", ck_NULL_KEY, ""); }
        }
    }
    else
    {
        if( giDrawn ) { llResetAnimationOverride("ALL"); }
        llRegionSayTo(gkOwnerKey,ci_SYSTEM_CHANNEL,gsCommPrefix+"1|0.0|0|"+(string)giParticle);
        llSleep(0.5);

        llListenRemove(giSystemListen);
        llListenRemove(giInputListen);
        llListenRemove(giDCSListen);

        giInputListen = llListen(oiCommChan, "", gkOwnerKey, osCommPrim);

        if( giDrawn )
        {
            giDrawn = 0;
            llReleaseControls();
        }
        llMessageLinked(ci_NEG_ONE,0x00000002,"1|"+(string)giParticle,"0");
        if( oiBasicAlpha ) { llSetLinkAlpha(ci_NEG_ONE, ofBasicAlphaShow, ci_NEG_ONE); }

        giPermissions = 0;
    }
}

unCombatModes()
{
    if( giCombatMode )
    {
        giCombatControl = 2;
        giControlHold = ci_CONTROL_LMB;
        gvCombatParam = <0.5,2.5,1.396263401595464>;
        if( giDCSBridge ) { giDCSListen = llListen(giDCSChannel, "", ck_NULL_KEY, ""); }
    }
    else
    {
        giCombatControl = 3;
        giControlHold = CONTROL_LBUTTON;
        gvCombatParam = <0.3,2.0,1.5707963267948970>;
        llListenRemove(giDCSListen);
    }

    gsTempStr = (string)giCombatControl+"|"+(string)gvCombatParam;
    llRegionSayTo(gkOwnerKey,ci_SYSTEM_CHANNEL,gsCommPrefix+"3|"+(string)giDrawn+"|"+(string)giParticle+"|"+gsTempStr);
    llMessageLinked(ci_NEG_ONE,0x08000000,gsTempStr,"");
    unReportModes();
}

unReportModes()
{
    gsTempStr = "<< System: ";
    if( giCombatMode ) { gsTempStr += "DynamicCombatSystem"; }
    else { gsTempStr += "CommunityCombatSystem"; }

    gsTempStr += " • Controls: ";
    if( giCombatControl == 2 ) { gsTempStr += "LeftMouseArrow"; }
    else { gsTempStr += "3rdPersonLeftMouseArrow"; }

    llOwnerSay(gsTempStr+" • Stats: "+llGetSubString((string)gvCombatParam.x,0,3)+"/"+llGetSubString((string)gvCombatParam.y,0,3)+"/"+(string)llFloor(gvCombatParam.z*114.5915590261646416)+" >>");
}

unInitAnims()
{
    if( llGetInventoryType(gsNotecardName) == 7 )
    {
        llOwnerSay("<< Loading Animation Set Data... >>");

        giLoadLine = 0;
        gkLoadRequest = llGetNotecardLine(gsNotecardName,giLoadLine);

        gsConfigString = "";
    }
    else
    {
        llOwnerSay("<< Config Notecard Not Found: Loading Empty Config. >>");

        giLoadLine = ci_NEG_ONE;
        gkLoadRequest = ck_NULL_KEY;

        gsConfigString = cs_NULL_ANIM_CONFIG;
        unParseAnims();
    }

    /*
    llOwnerSay("Mem: "+(string)llGetFreeMemory());
    llOwnerSay("Time :"+(string)llGetTime());
    */
}

unParseAnims()
{
    /*
    llOwnerSay("Parsing");
    llOwnerSay("Mem: "+(string)llGetFreeMemory());
    llOwnerSay("Time :"+(string)llGetTime());
    */

    glActiveEfcts = [];
    glStanceAnims = [];
    glActiveAttk = [];

    list vlParsed = llParseStringKeepNulls(gsConfigString,["✕"],[]);
    gsConfigString = "";

    glActiveEfcts = llParseStringKeepNulls( llList2String(vlParsed,0), ["|"],[] );
    glStanceAnims = llParseStringKeepNulls( llList2String(vlParsed,1), ["|"],[] );
    glActiveAttk = llParseStringKeepNulls( llList2String(vlParsed,2), ["|"],[] );

    vlParsed = llParseString2List( llList2String(vlParsed,3), ["|"],[] );
    giAttkNoDir = (integer)llList2String(vlParsed,0);
    giActiveAttk = (integer)llList2String(vlParsed,1);
    giActiveAttkDI = (integer)llList2String(vlParsed,2);
    giActiveAttkLI = (integer)llList2String(vlParsed,3);
    giActiveAttkRI = (integer)llList2String(vlParsed,4);

    vlParsed = [];

    llOwnerSay("<< Animation Load Complete. >>");
    /*
    llOwnerSay("Mem: "+(string)llGetFreeMemory());
    llOwnerSay("Time :"+(string)llGetTime());
    */

    if( giDrawn )
    {
        for(giTempInt = 0; giTempInt <= 21; ++giTempInt)
        {
            if( gsTempStr = llList2String(glStanceAnims,giTempInt) )
            {
                llSetAnimationOverride( llList2String(cl_ANIM_STATES,giTempInt), gsTempStr );
            }
            else { llResetAnimationOverride( llList2String(cl_ANIM_STATES,giTempInt) ); }
        }

        if( gsCurSoun ) { llStopSound(); gsCurSoun = ""; }
        if( giAmbSound )
        {
            if( gsTempStr = llList2String(glActiveEfcts,0) ) { llLoopSound(gsCurSoun = gsTempStr, 1.0); }
        }
    }
}

unToggleDrawShea()
{
    if( giPermissions && giAttached )
    {
        if( giDrawn )
        {
            gfTempFloat = llList2Float(glActiveEfcts,6);

            gsTempStr = "0|"+(string)giParticle;
            llRegionSayTo(gkOwnerKey,ci_SYSTEM_CHANNEL,gsCommPrefix+"1|"+(string)gfTempFloat+"|"+gsTempStr);
            llMessageLinked(ci_NEG_ONE,0x00000002,gsTempStr,"0");

            gsTempStr = llList2String(glActiveEfcts,4);
            if( gsTempStr ) { llStartAnimation(gsTempStr); }
            gsTempStr = llList2String(glActiveEfcts,5);
            if( gsTempStr ) { llTriggerSound(gsTempStr,1.0); }

            llResetAnimationOverride("ALL");

            llReleaseControls();
            giPermissions = 0;
            llRequestPermissions(gkOwnerKey, ci_PERM_CONTROLANIM);

            giDrawn = 0;

            if( gfTempFloat ) { llSleep(gfTempFloat); }
            if( oiBasicAlpha ) { llSetLinkAlpha(ci_NEG_ONE, ofBasicAlphaHide, ci_NEG_ONE); }

            if( gsCurSoun ) { llStopSound(); gsCurSoun = ""; }
        }
        else
        {
            gfTempFloat = llList2Float(glActiveEfcts,3);

            gsTempStr = "1|"+(string)giParticle;
            llRegionSayTo(gkOwnerKey,ci_SYSTEM_CHANNEL,gsCommPrefix+"1|"+(string)gfTempFloat+"|"+gsTempStr);
            llMessageLinked(ci_NEG_ONE,0x00000002,gsTempStr,"1");

            gsTempStr = llList2String(glActiveEfcts,1);
            if( gsTempStr ) { llStartAnimation(gsTempStr); }
            gsTempStr = llList2String(glActiveEfcts,2);
            if( gsTempStr ) { llTriggerSound(gsTempStr,1.0); }

            for(giTempInt = 0; giTempInt <= 21; ++giTempInt)
            {
                if( gsTempStr = llList2String(glStanceAnims,giTempInt) )
                {
                    llSetAnimationOverride( llList2String(cl_ANIM_STATES,giTempInt), gsTempStr );
                }
                else { llResetAnimationOverride( llList2String(cl_ANIM_STATES,giTempInt) ); }
            }

            llTakeControls(ci_ALL_CONTROLS, 1, 1);

            giDrawn = 1;

            if( gfTempFloat ) { llSleep(gfTempFloat); }
            if( oiBasicAlpha ) { llSetLinkAlpha(ci_NEG_ONE, ofBasicAlphaShow, ci_NEG_ONE); }

            if( giAmbSound )
            {
                if( gsTempStr = llList2String(glActiveEfcts,0) ) { llLoopSound(gsCurSoun = gsTempStr, 1.0); }
            }
        }
    }
}

default
{
    on_rez(integer eiStart) { unInitSystem(llGetAttached() == 0); }
    state_entry()
    {
        unInitDefaults();
        unInitSystem(1);
        unInitAnims();
    }
    attach(key ekID) { unCheckAttach(); }

    dataserver(key ekID, string esData)
    {
        if( ekID != gkLoadRequest ) { return; }

        if( esData == cs_EOF || esData == "//EOF//" )
        {
            giLoadLine = ci_NEG_ONE;
            gkLoadRequest = ck_NULL_KEY;

            unParseAnims();
        }
        else
        {
            if( llStringLength(esData) && llSubStringIndex(esData,"//") != 0 )
            {
                integer viIndex = llSubStringIndex(esData, "★");
                if( ~viIndex ) { esData = llDeleteSubString(esData,0,viIndex); }
                gsConfigString += esData;
            }

            ++giLoadLine;
            gkLoadRequest = llGetNotecardLine(gsNotecardName,giLoadLine);
        }
    }

    run_time_permissions(integer eiPerms)
    {
        if( eiPerms & ci_PERM_CONTROLANIM ) { giPermissions = 1; }
        else if( eiPerms & 0x00000020 ) { llDetachFromAvatar(); }
    }

    listen(integer eiChannel, string esName, key ekID, string esMessage) 
    {
        if( llGetOwnerKey(ekID) == gkOwnerKey )
        {
            if( eiChannel == giDCSChannel )
            {
                esMessage = llToLower(esMessage);
                if( (esMessage == "draw" && !giDrawn) || (esMessage == "release" && giDrawn) ) { unToggleDrawShea(); }
            }
            else if( eiChannel == ci_SYSTEM_CHANNEL )
            {
                if( llGetSubString(esMessage,0,36) != gsCommPrefix ) { return; }
                esMessage = llDeleteSubString(esMessage,0,36);

                gsTempStr = llGetSubString(esMessage,0,0);
                esMessage = llDeleteSubString(esMessage,0,1);

                //list vlInput = llParseStringKeepNulls(esMessage,["|"],[]);

                if( gsTempStr == "0" ) { llMessageLinked(ci_NEG_ONE,0x00000001,esMessage,"0"); }
                else if( gsTempStr == "4" ) { llRegionSayTo(gkOwnerKey,ci_SYSTEM_CHANNEL,gsCommPrefix+"3|"+(string)giDrawn+"|"+(string)giParticle+"|"+(string)giCombatControl+"|"+(string)gvCombatParam); }
            }
            else if( eiChannel == oiCommChan ) { llMessageLinked(ci_NEG_ONE,0x00000001,llStringTrim(esMessage,3),"1"); }
        }
    }

    link_message(integer eiSrc, integer eiNum, string esStr, key ekID)
    {
        if( (eiNum & 0x00000001) == 0 ) { return; }
        else if( eiNum == 0x00000001 )
        {
            if( ekID == "1" ) { llRegionSayTo(gkOwnerKey,ci_SYSTEM_CHANNEL,gsCommPrefix+"0|"+esStr); }

            string vsStrLower = llToLower(esStr);

            if( vsStrLower == osWeaponType || vsStrLower == "owsto" ) { unToggleDrawShea(); }
            else if( vsStrLower == "owsdr" || vsStrLower == "draw" || vsStrLower == "draw "+osWeaponType )
            {
                if( !giDrawn ) { unToggleDrawShea(); }
            }
            else if( vsStrLower == "owssh" || vsStrLower == "sheath" || vsStrLower == "sheath "+osWeaponType )
            {
                if( giDrawn ) { unToggleDrawShea(); }
            }
            else if( vsStrLower == "modes" ) { unReportModes(); }
            else if( vsStrLower == osCommDCSB )
            {
                if( giDCSBridge )
                {
                    llListenRemove(giDCSListen);
                    giDCSListen = 0;
                    giDCSBridge = 0;
                    gsTempStr = "OFF. >>";
                }
                else
                {
                    giDCSListen = llListen(giDCSChannel,"",ck_NULL_KEY,"");
                    giDCSBridge = 1;
                    gsTempStr = "ON. >>";
                }
                llOwnerSay("<< DCS Personal Channel Bridge "+gsTempStr);
            }
            else if( vsStrLower == osCommCmbt )
            {
                giCombatMode = !giCombatMode;
                unCombatModes();
            }
            else if( llSubStringIndex(vsStrLower, osCommAnim) == 0 )
            {
                /* Changing Set Mid-Load should not hurt anything, but code is kept commented incase it's needed later.
                if( ~giLoadLine )
                {
                    llOwnerSay("<< Loading Animations. Please Wait. >>");
                    return;
                }
                */

                gsTempStr = ".anim " + llGetSubString( vsStrLower, llStringLength(osCommAnim)+1, ci_NEG_ONE );
                if( gsTempStr == gsNotecardName ) { llOwnerSay("<< That Animation Set is currently in use. >>"); }
                else if( llGetInventoryType(gsTempStr) == 7 )
                {
                    gsNotecardName = gsTempStr;
                    unInitAnims();
                }
                else { llOwnerSay("<< Config Notecard Not Found. Animation Set Not Changed. >>"); }
            }
            else if( vsStrLower == osCommAmbS )
            {
                giAmbSound = !giAmbSound;

                if( giAmbSound )
                {
                    if( gsTempStr = llList2String(glActiveEfcts,0) ) { llLoopSound(gsCurSoun = gsTempStr, 1.0); }
                    gsTempStr = "ON. >>";
                }
                else
                {
                    if( gsCurSoun ) { llStopSound(); gsCurSoun = ""; }
                    gsTempStr = "OFF. >>";
                }

                llOwnerSay("<< Ambient Sound "+gsTempStr);
            }
            else if( vsStrLower == osCommPart )
            {
                giParticle = !giParticle;

                gsTempStr = (string)(giDrawn||!giAttached)+"|"+(string)giParticle;
                llRegionSayTo(gkOwnerKey,ci_SYSTEM_CHANNEL,gsCommPrefix+"1|0.0|"+gsTempStr);
                llMessageLinked(ci_NEG_ONE,0x00000002,gsTempStr,(string)giDrawn);

                if( giParticle ) { gsTempStr = "ON. >>"; }
                else { gsTempStr = "OFF. >>"; }
                llOwnerSay("<< Particles "+gsTempStr);
            }
            else if( vsStrLower == osCommPrim )
            {
                llRegionSayTo(gkOwnerKey,ci_SYSTEM_CHANNEL,gsCommPrefix+"2");
                llMessageLinked(ci_NEG_ONE,0x00000004,"","");

                llOwnerSay("<< Refreshing PrimCache for Plugins that use it. >>");
            }
        }
    }

    control(key ekID, integer eiHeld, integer eiChange)
    {
        if( !eiChange ) { return; }

        gfTempFloat = llGetTime();
        if( gfTempFloat < gfNextAttack ) { return; }

        if( (eiHeld & giControlHold) && ((eiChange & eiHeld) & ci_CONTROL_ARROW) )
        {
            //llMessageLinked(LINK_SET,0x10000000,"","");
            llSensor("", "", 1, gvCombatParam.y, gvCombatParam.z);

            integer viIndex;

            if( giAttkNoDir == 1 ) { viIndex = 0; giTempInt = giActiveAttk; }
            else
            {
                if( eiChange & eiHeld & 0x00000001 ) { viIndex = 0; giTempInt = giActiveAttkDI-viIndex; }
                else if( eiChange & eiHeld & 0x00000002 ) { viIndex = giActiveAttkDI; giTempInt = giActiveAttkLI-viIndex; }
                else if( eiChange & eiHeld & ci_CONTROL_ANYLEFT ) { viIndex = giActiveAttkLI; giTempInt = giActiveAttkRI-viIndex; }
                else if( eiChange & eiHeld & ci_CONTROL_ANYRIGHT ) { viIndex = giActiveAttkRI; giTempInt = giActiveAttk-viIndex; }
            }

            if( giTempInt )
            {
                giTempInt = ( viIndex + llFloor(llFrand(giTempInt)) ) * 4;

                if( gsTempStr = llList2String(glActiveAttk, giTempInt) ) { llStartAnimation(gsTempStr); }
                gsMisSound = llList2String(glActiveAttk, giTempInt + 1);
                gsHitSound = llList2String(glActiveAttk, giTempInt + 2);
                gsHitEfect = llList2String(glActiveAttk, giTempInt + 3);
            }
            gfNextAttack = (gfTempFloat + gvCombatParam.x);
        }
    }

    sensor(integer eiNum)
    {
        gkTempKey = llDetectedKey(0);
        llMessageLinked(ci_NEG_ONE,0x20000000,"",gkTempKey);

        if( gsHitSound ) { llTriggerSound(gsHitSound,1.0); }
        if( giParticle )
        {
            if( gsHitEfect )
            {
                vector vvTargSize = llGetAgentSize(gkTempKey);
                llRezObject( gsHitEfect, llList2Vector( llGetObjectDetails(gkTempKey,[3]), 0 ) + <0,0,vvTargSize.z / 4>, cv_ZERO_VECTOR, cr_ZERO_ROTATION, 1 );
            }
        }
    }
    no_sensor()
    {
        llMessageLinked(ci_NEG_ONE,0x40000000,"","");

        if( gsMisSound ) { llTriggerSound(gsMisSound,1.0); }
    }
}