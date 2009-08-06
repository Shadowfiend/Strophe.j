// Available roles.
SRRoomVisitor     = 'visitor';
SRRoomModerator   = 'moderator';
SRRoomParticipant = 'participant';

// Available affiliations.
SRRoomOwner         = 'owner';
SRRoomAdmin         = 'admin';
SRRoomMember        = 'member';
SRRoomNoAffiliation = 'none';

/*!
 * The SRRoomOccupant class represents an occupant in a Jabber Multi-User Chat
 * room. This class is NOT a subclass of SRUser, because the information
 * available about room occupants is typically different in nature than that
 * available about a user on one's roster.
 *
 * Room occupants have a nick, and various pieces of information are available
 * regarding their role in the room.
 */
@implementation SRRoomOccupant : CPObject
{
    CPString nick        @accessors(readonly);
    CPString role        @accessors(readonly);
    CPString affiliation @accessors(readonly) ;
}

+ (SRRoomOccupant)occupantWithNick:(CPString)aNick mucInfo:(id)mucInfo
{
    return [[self alloc] initWithNick:aNick mucInfo:mucInfo];
}

- (SRRoomOccupant)initWithNick:(CPString)aNick mucInfo:(id)mucInfo
{
    nick = aNick;

    var infoItem = mucInfo.find('item');
    role = infoItem.attr('role');
    affiliation = infoItem.attr('affiliation');

    return self;
}

@end
