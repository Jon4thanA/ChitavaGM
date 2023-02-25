/*  
 *           PointToPoint Functions
 *  (c) Copyright 2010, Blacklite & <__Ethan__>
 *
 */


stock Float:PointToPoint2D(Float:x1,Float:y1,Float:x2,Float:y2)
{
	return floatsqroot(floatadd(floatpower(x2-x1,2),floatpower(y2-y1,2)));
}
stock Float:PointToPoint3D(Float:x1,Float:y1,Float:z1,Float:x2,Float:y2,Float:z2)
{
	return floatsqroot(floatadd(floatadd(floatpower(x2-x1,2),floatpower(y2-y1,2)),floatpower(z2-z1,2)));
}

stock Float:GetPlayerDistanceToPlayer(playerid, targetid)
{
    new Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:z2;
    GetPlayerPos(playerid, x, y, z);
    GetPlayerPos(targetid, x2, y2, z2);
    return PointToPoint2D(x, y, x2, y2);
}
