@import "SRObject.j"

/*!
 * The SRMessage class represents a Jabber message in Strophe.j. It wraps a
 * strophe.js stanza and provides some convenience methods on it. In particular,
 * it carries SRUser objects for the from and to users. It also provides a
 * convenience method replyWithStanza: that takes a strophe.js stanza and wraps
 * it in an SRMessage object with the appropriate from and to users. When the
 * stanza property of this new message is accessed, it is correctly set up with
 * the from and to JIDs.
 */
@implementation SRMessage : SRObject
{
    id stanza;
    SRUser toUser;
    SRUser fromUser;
}

+ (SRMessage)messageFrom:(SRUser)fromUser
                      to:(SRUser)toUser
              withStanza:(id)aJabberStanza
{
    return [[self alloc] initWithFrom:fromUser to:toUser stanza:aJabberStanza];
}

+ (SRMessage)messageWithStanza:(id)aJabberStanza
{
    return [[self alloc] initWithStanza:aJabberStanza];
}

- (SRMesssage)initWithFrom:(SRUser)fromUser
                        to:(SRUser)toUser
                    stanza:(id)aJabberStanza
{
    fromUser = fromUser;
    toUser = toUser;
    stanza = aJabberStanza;

    if (stanza.elementName == "msg")
    {
        stanza.setAttribute('from', [fromUser JID]);
        stanza.setAttribute('to', [toUser JID]);
    }
    else
    {
        stanza = $msg({ from: [fromUser JID], to: [toUser JID] }).cnode(stanza)
                                                                 .tree();
    }
}

- (SRMessage)initWithStanza:(id)aJabberStanza
{
    stanza = aJabberStanza;
    toUser = [SRUser userWithJID:aJabberStanza.getAttribute('to') connection:nil];
    fromUser = [SRUser userWithJID:aJabberStanza.getAttribute('from') connection:nil];

    return self;
}

- (id)stanza
{
    return stanza;
}

- (SRUser)toUser
{
    return toUser;
}

- (CPString)toJID
{
    return [toUser JID];
}

- (SRUser)fromUser
{
    return fromUser;
}

- (CPString)fromJID
{
    return [fromUser JID];
}

- (SRMessage)replyWithStanza:(id)aJabberStanza
{
    var msg = [SRMessage messageFrom:toUser
                                  to:fromUser
                          withStanza:aJabberStanza];
}

@end
