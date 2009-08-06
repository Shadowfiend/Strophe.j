@import "SRObject.j"
@import "SRRoomOccupant.j"

SRRoomNotJoined = 0;
SRRoomJoining   = 1;
SRRoomJoined    = 2;

var SRMUCNS = 'http://jabber.org/protocol/muc';
var SRMUCUserNS = SRMUCNS + '#user';

/*!
 * The SRRoom class is used to manage a Strophe.j MUC chat. It wraps all of the
 * communications that have to happen to join and leave a room, provide
 * presence information, and obtain a list of participants, as well as the
 * traditional functionality of handling room messages.
 *
 * An SRRoom delegate can receive a variety of notifications regarding the
 * room's status, including:
 *  - didJoinRoom:asOccupant: for the initial completion of the room joining,
 *  - room:didReceiveMessage: for reception of room messages,
 *  - room:didHaveUserJoin: for new users joining the room, and
 *  - room:didHaveUserLeave: for users leaving the room.
 *
 * Note that room:didHaveUserJoin: is invoked once for every user that joins the
 * room externally, as well.
 *
 * Rooms expose the SRRoomOccupant object that represents their own occupant via
 * the ownOccupant getter. This is an SRRoomOccupant that corresponds to the
 * current user. It carries room-specific information about that user.
 */
@implementation SRRoom : SRObject
{
    SRJID JID;
    SRRoomOccupant ownOccupant @accessors(readonly);
    id occupants;
    unsigned joinState;

    DelegateProxy delegateProxy;
}

+ (SRRoom)roomWithJID:(CPString)aJID connection:(SRJabberConnection)aConnection
             delegate:(id)aDelegate
{
    return [[self alloc] initWithJID:aJID connection:aConnection
                            delegate:aDelegate];
}

- (SRRoom)initWithJID:(CPString)aJID connection:(SRJabberConnection)aConnection
             delegate:(id)aDelegate
{
    [super initWithConnection:aConnection]

    JID = [SRJID JIDWithStringJID:aJID];
    delegateProxy = [DelegateProxy proxyWithDelegate:aDelegate];
    joinState = SRRoomNotJoined;
    occupants = {};

    return self;
}

- (void)join
{
    [connection addDelegate:self];
    [connection sendStanza:[self constructPresence]];
    joinState = SRRoomJoining;
}

/*!
 * Constructs the presence stanza to send to a room. Certain aspects of it are
 * changed depending on the action that is currentlyt aking place (e.g., joining
 * or leaving).
 */
- (id)constructPresence
{
    var presenceJID = [JID bare];
    var userName = [[connection currentUser] name];
    presenceJID += "/" + userName;

    // As per XEP-0045, presence stanza to the room JID with resource being our
    // desired nick. As suggested in the same XEP, we add an x element with the
    // MUC namespace.
    return $pres({ to:   presenceJID,
                   from: [[connection currentUser] JID] })
                .c('x', { xmlns: SRMUCNS })
                .tree();
}

- (void)connection:(SRJabberConnection)aConnection
 didReceiveMessage:(SRMessage)aMessage
{
    var stanza = jQuery([aMessage stanza]);
    if (stanza.is('presence[from^=' + [JID bare] + ']'))
    {
        if (stanza.attr('type') == 'error')
            console.error('Crap. We got an error. Die now, please!');
        else
        {
            var from = [SRJID JIDWithStringJID:stanza.attr('from')];
            var nick = [from resource];
            var mucInfo = stanza.find('x[xmlns=' + SRMUCUserNS + ']');

            if (nick != [[connection currentUser] name])
            {
                occupants[nick] =
                    [SRRoomOccupant occupantWithNick:nick
                                             mucInfo:mucInfo];

                [delegateProxy room:self didHaveUserJoin:occupants[nick]]
            }
            else if (joinState != SRRoomJoined)
            {
                ownOccupant = [SRRoomOccupant occupantWithNick:nick
                                                       mucInfo:mucInfo];

                joinState = SRRoomJoined;
                [delegateProxy didJoinRoom:self asOccupant:ownOccupant]
            }
        }
    }
    else if (stanza.attr('type') == 'groupchat')
        [delegateProxy room:self didReceiveMessage:aMessage]
}

@end
