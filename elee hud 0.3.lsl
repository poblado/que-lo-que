
///BEGIN CONFIG///
string osWeaponCreator = "26b8ddea-ee70-470c-8303-39baacceadd7";         // Avatar UUID. This must match in MainHand, OffHand, Sheath and HUD Scripts.
integer oiWeaponNumber = 1;                                     // Comms Filter - This should be non-zero and different for each Weapon. This must match in MainHand, OffHand, Sheath and HUD Scripts.
///*END CONFIG*///

integer ci_SYSTEM_CHANNEL = -1192001000;                        // System Communications Channel for A01 Project.

integer giTempInt;
string cDraw = "OWSTO";

key gkOwnerKey;
string gsOwnerName;
string gsCommPrefix;
//integer giSystemListen;

unStartUp()
{
    gkOwnerKey = llGetOwner();
    gsOwnerName = llKey2Name(gkOwnerKey);

    gsCommPrefix = "A01|"+llMD5String(osWeaponCreator,oiWeaponNumber)+"|0|";

    //giSystemListen = llListen(ci_SYSTEM_CHANNEL,"",NULL_KEY,"");
}

integer functTest(integer prim, integer cara){
    if(llDetectedLinkNumber(0) == prim && llDetectedTouchFace(0) == cara){
        return TRUE;
    }
    else{
        return FALSE;
    }
}



default
{
    state_entry()
    {
        llSetMemoryLimit(8192);
        unStartUp();
    }
    on_rez(integer eiStart) { unStartUp(); }
    touch_start(integer eiNum)
    {
        //llSay(0, (string)llDetectedLinkNumber(0) +", "+ (string)llDetectedTouchFace(0));
       if( llDetectedKey(0) == gkOwnerKey )
        {
            if(functTest(2, 0) == TRUE){
                   
              //llOwnerSay( (string)gsCommPrefix+cDraw);      
              llRegionSayTo( gkOwnerKey, ci_SYSTEM_CHANNEL, gsCommPrefix+cDraw );
         
            }
        }
    }
}
